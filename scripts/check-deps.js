#!/usr/bin/env node
/**
 * Dependency Version Verifier + Auto-Upgrader + Strict Mode
 * Automatically upgrades missing/outdated packages, logs actions,
 * and fails the process if critical dependencies are unsafe.
 */

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const LOG_FILE = path.resolve(__dirname, "../dependency-upgrades.log");

const safeVersions = {
  ws: "8.18.0",
  pino: "10.0.0",
  "@metamask/sdk": "0.33.0",
  wagmi: "2.18.1",
  "@safe-global/safe-apps-sdk": "9.0.0",
};

function log(message) {
  console.log(message);
  fs.appendFileSync(LOG_FILE, `${new Date().toISOString()} - ${message}\n`);
}

function getVersion(pkg) {
  try {
    const version = execSync(`npm ls ${pkg} --depth=0 --json`, {
      stdio: ["pipe", "pipe", "ignore"],
    });
    const data = JSON.parse(version);
    return data.dependencies?.[pkg]?.version || "not installed";
  } catch {
    return "not installed";
  }
}

function compareVersions(a, b) {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);
  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    if ((pa[i] || 0) > (pb[i] || 0)) return 1;
    if ((pa[i] || 0) < (pb[i] || 0)) return -1;
  }
  return 0;
}

function upgradePackage(pkg, targetVersion) {
  log(`🔄 Installing/Upgrading ${pkg}@${targetVersion}...`);
  try {
    execSync(`npm install ${pkg}@${targetVersion} --legacy-peer-deps`, {
      stdio: "inherit",
    });
    log(`✅ ${pkg} upgraded successfully!`);
    return true;
  } catch (err) {
    log(`❌ Failed to upgrade ${pkg}: ${err.message}`);
    return false;
  }
}

(async () => {
  log("🔍 Starting strict dependency check...");

  let hasCriticalFailures = false;
  const summary = { ok: [], upgraded: [], failed: [], missing: [] };

  for (const [pkg, safeVer] of Object.entries(safeVersions)) {
    const currentVer = getVersion(pkg);

    if (currentVer === "not installed") {
      log(`⚠️  ${pkg} not installed`);
      summary.missing.push(pkg);
      const success = upgradePackage(pkg, safeVer);
      if (!success) hasCriticalFailures = true;
      success ? summary.upgraded.push(pkg) : summary.failed.push(pkg);
      continue;
    }

    const ok = compareVersions(currentVer, safeVer) >= 0;
    log(
      `${pkg}@${currentVer} — ${
        ok ? "✅ OK" : `❌ Below safe version (${safeVer}+ required)`
      }`
    );
    if (!ok) {
      const success = upgradePackage(pkg, safeVer);
      if (!success) hasCriticalFailures = true;
      success ? summary.upgraded.push(pkg) : summary.failed.push(pkg);
    } else {
      summary.ok.push(pkg);
    }
  }

  log("\n📊 Strict dependency check summary:");
  log(`✅ OK: ${summary.ok.join(", ") || "None"}`);
  log(`⚠️  Upgraded: ${summary.upgraded.join(", ") || "None"}`);
  log(`❌ Failed: ${summary.failed.join(", ") || "None"}`);
  log(`⚠️  Missing: ${summary.missing.join(", ") || "None"}`);
  log("✅ Dependency check complete.\n");

  if (hasCriticalFailures) {
    log(
      "❌ One or more critical dependencies failed to install/upgrade. Exiting with error code 1."
    );
    process.exit(1);
  }

  console.log("\n✅ All done! See dependency-upgrades.log for details.");
})();
