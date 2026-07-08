#!/usr/bin/env node

process.argv = [process.argv[0], process.argv[1], "--check"];
import("./build-agent-adapters.js").catch((error) => {
  console.error(error);
  process.exit(1);
});
