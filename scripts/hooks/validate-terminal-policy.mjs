#!/usr/bin/env node

const readStdin = async () => {
  const chunks = [];

  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks).toString("utf8").trim();
};

const allow = () => ({
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
  },
});

const deny = (reason) => ({
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: reason,
  },
});

const QUALITY_GATE_COMMAND_PATTERNS = [
  /\bpnpm\s+check(?::fix)?\b/i,
  /\bpnpm\s+format(?::check)?\b/i,
  /\bpnpm\s+lint(?::fix)?\b/i,
  /\bpnpm\s+typecheck\b/i,
  /\bpnpm\s+test(?::[\w-]+)?\b/i,
  /\bpnpm\s+exec\s+jest\b/i,
  /\bpnpm\s+openapi(?::(?:pull|gen))?\b/i,
  /\bpnpm\s+biome\b/i,
  /(?:^|[\s;|])(?:\.\/)?scripts\/quality-gates\.sh\b/i,
];

const QUALITY_GATE_INTENT_PATTERN = /\bquality(?:-|\s)?gates?\b/i;

const getCommandContext = (payload) => {
  const toolName = payload?.tool_name;
  const toolInput = payload?.tool_input ?? {};

  if (toolName === "run_in_terminal") {
    return {
      toolName,
      command: String(toolInput.command ?? ""),
      explanation: String(toolInput.explanation ?? ""),
      goal: String(toolInput.goal ?? ""),
    };
  }

  if (toolName === "create_and_run_task") {
    const task = toolInput.task ?? {};
    const args = Array.isArray(task.args) ? task.args.join(" ") : "";

    return {
      toolName,
      command: [String(task.command ?? ""), args].filter(Boolean).join(" "),
      explanation: "",
      goal: String(task.label ?? ""),
    };
  }

  return null;
};

const isExplicitQualityGateCommand = (command) => QUALITY_GATE_COMMAND_PATTERNS.some((pattern) => pattern.test(command));

const hasQualityGateIntent = (text) => QUALITY_GATE_INTENT_PATTERN.test(text);

const isFrontContainerQualityGateCommand = (command) => {
  const isDockerExec = /docker\s+(?:compose\s+exec|exec)\b/i.test(command);
  const mentionsPnpm = /\bpnpm\b/i.test(command);
  const targetsFront = /(?:^|[\s'"`])front(?:[\s'"`]|$)|-front-\d+|teamdev-2026-front|\bcd\s+\/app\b/i.test(command);

  return isDockerExec && targetsFront && (mentionsPnpm || isExplicitQualityGateCommand(command));
};

const isQualityGateInstallCommand = (command, explanation, goal) => {
  const contextText = `${explanation}\n${goal}`;
  const isDependencyInstall = /\bpnpm\s+(?:install|i)\b/i.test(command) || /\bnpm\s+install(?:\s+-g)?\b/i.test(command);
  const isPackageAdd = /\bpnpm\s+add\b/i.test(command);
  const explicitQualityGateCommand = isExplicitQualityGateCommand(command);
  const explicitQualityGateIntent = hasQualityGateIntent(contextText);

  return (isDependencyInstall && (explicitQualityGateIntent || explicitQualityGateCommand)) || (isPackageAdd && explicitQualityGateIntent);
};

const main = async () => {
  const rawInput = await readStdin();

  if (!rawInput) {
    process.stdout.write(JSON.stringify(allow()));
    return;
  }

  let payload;

  try {
    payload = JSON.parse(rawInput);
  } catch {
    process.stdout.write(JSON.stringify(allow()));
    return;
  }

  const context = getCommandContext(payload);

  if (!context) {
    process.stdout.write(JSON.stringify(allow()));
    return;
  }

  const { command, explanation, goal } = context;

  if (isFrontContainerQualityGateCommand(command)) {
    process.stdout.write(
      JSON.stringify(
        deny(
          "Frontend pnpm quality-gate commands must run from the active worktree's teamdev-2026-front directory on the host shell, not through the frontend container.",
        ),
      ),
    );
    return;
  }

  if (isQualityGateInstallCommand(command, explanation, goal)) {
    process.stdout.write(
      JSON.stringify(
        deny(
          "Do not run pnpm/npm install commands just to make frontend quality gates pass. Report the missing dependency or setup blocker instead.",
        ),
      ),
    );
    return;
  }

  process.stdout.write(JSON.stringify(allow()));
};

await main();