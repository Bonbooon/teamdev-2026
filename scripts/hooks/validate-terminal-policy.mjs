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

const isFrontContainerPnpmCommand = (command) => {
  const isDockerExec = /docker\s+(?:compose\s+exec|exec)\b/i.test(command);
  const mentionsPnpm = /\bpnpm\b/i.test(command);
  const targetsFront = /(?:^|[\s'"`])front(?:[\s'"`]|$)|-front-\d+|teamdev-2026-front|\bcd\s+\/app\b/i.test(command);

  return isDockerExec && mentionsPnpm && targetsFront;
};

const isQualityGateInstallCommand = (command, explanation, goal) => {
  const commandText = `${command}\n${explanation}\n${goal}`;
  const isInstall = /\bpnpm\s+(?:install|i|add)\b/i.test(command) || /\bnpm\s+install(?:\s+-g)?\b/i.test(command);
  const qualityTerms = /\b(?:quality(?:-|\s)?gates?|check(?::fix)?|format(?::check)?|lint(?::fix)?|typecheck|test|jest|biome|openapi(?:\:gen)?|build)\b/i;

  return isInstall && qualityTerms.test(commandText);
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

  if (isFrontContainerPnpmCommand(command)) {
    process.stdout.write(
      JSON.stringify(
        deny(
          "Frontend pnpm quality gates must run from the active worktree's teamdev-2026-front directory on the host shell, not through the frontend container.",
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