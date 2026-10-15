import { useEffect, useState } from "react";
import { verifySync } from "otplib";
import { apiFetch } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import type { MfaStatusRow } from "../types";

const QR_ENDPOINT = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=";
const BACKUP_CODES_KEY = "homescan_backup_codes";

export default function SecurityPage() {
  const { user } = useAuth();
  const [enabled, setEnabled] = useState(user?.mfa_enabled ?? false);
  const [setup, setSetup] = useState<{ secret: string; provisioning_uri: string } | null>(null);
  const [code, setCode] = useState("");
  const [backupCodes, setBackupCodes] = useState<string[]>(() =>
    JSON.parse(localStorage.getItem(BACKUP_CODES_KEY) ?? "[]"),
  );
  const [team, setTeam] = useState<MfaStatusRow[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!enabled) {
      apiFetch<{ secret: string; provisioning_uri: string }>("/mfa/setup", { method: "POST" }).then(setSetup);
    }
  }, [enabled]);

  useEffect(() => {
    if (user?.role === "admin") apiFetch<MfaStatusRow[]>("/mfa/status").then(setTeam);
  }, [user]);

  async function enable() {
    setError(null);
    // Catch typos before the round trip.
    if (!setup || !verifySync({ secret: setup.secret, token: code }).valid) {
      setError("Code doesn't match, check your authenticator app");
      return;
    }
    const res = await apiFetch<{ backup_codes: string[] }>("/mfa/enable", {
      method: "POST",
      body: JSON.stringify({ code }),
    });
    localStorage.setItem(BACKUP_CODES_KEY, JSON.stringify(res.backup_codes));
    setBackupCodes(res.backup_codes);
    setEnabled(true);
  }

  async function disable() {
    if (!window.confirm("Turn off two-factor authentication?")) return;
    await apiFetch("/mfa", { method: "DELETE" });
    localStorage.removeItem(BACKUP_CODES_KEY);
    setBackupCodes([]);
    setEnabled(false);
  }

  async function reset(userId: number) {
    await apiFetch(`/users/${userId}/mfa/reset`, { method: "POST" });
    setTeam(team.map((row) => (row.user_id === userId ? { ...row, mfa_enabled: false } : row)));
  }

  return (
    <main>
      <h1>Security</h1>

      <section>
        <h2>Two-factor authentication</h2>
        {enabled ? (
          <>
            <p>Two-factor authentication is on.</p>
            <button onClick={disable}>Turn off</button>
          </>
        ) : setup ? (
          <>
            <p>Scan this with Google Authenticator, 1Password, or Authy, then enter the code.</p>
            <img src={QR_ENDPOINT + encodeURIComponent(setup.provisioning_uri)} alt="MFA QR code" />
            <p>
              Can't scan? Enter <code>{setup.secret}</code>
            </p>
            <input inputMode="numeric" value={code} onChange={(e) => setCode(e.target.value)} />
            <button onClick={enable}>Turn on</button>
            {error && <p role="alert">{error}</p>}
          </>
        ) : (
          <p>Loading...</p>
        )}

        {backupCodes.length > 0 && (
          <>
            <h3>Backup codes</h3>
            <p>Each code works if you lose your phone. We've saved them on this device too.</p>
            <ul>
              {backupCodes.map((c) => (
                <li key={c}>
                  <code>{c}</code>
                </li>
              ))}
            </ul>
          </>
        )}
      </section>

      {user?.role === "admin" && (
        <section>
          <h2>Team</h2>
          <table>
            <tbody>
              {team.map((row) => (
                <tr key={row.user_id}>
                  <td>{row.name}</td>
                  <td>{row.email}</td>
                  <td>{row.mfa_enabled ? "On" : "Off"}</td>
                  <td>{row.mfa_enabled && <button onClick={() => reset(row.user_id)}>Reset</button>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      )}
    </main>
  );
}
