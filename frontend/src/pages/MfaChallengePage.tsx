import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

export default function MfaChallengePage() {
  const { completeMfa } = useAuth();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const userId = Number(params.get("uid"));
  const [code, setCode] = useState("");
  const [useBackup, setUseBackup] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Submit as soon as a full TOTP code is typed.
  useEffect(() => {
    if (!useBackup && code.length === 6) {
      completeMfa(userId, code)
        .then(() => navigate("/projects"))
        .catch(() => {
          setError("That code didn't work, try again");
          setCode("");
        });
    }
  }, [code]);

  async function submitBackup() {
    try {
      await completeMfa(userId, code);
      navigate("/projects");
    } catch {
      setError("That backup code didn't work");
    }
  }

  return (
    <main>
      <h1>Two-factor authentication</h1>
      <p>{useBackup ? "Enter one of your backup codes." : "Enter the 6-digit code from your authenticator app."}</p>
      <input
        autoFocus
        inputMode={useBackup ? "text" : "numeric"}
        autoComplete="one-time-code"
        value={code}
        onChange={(e) => setCode(e.target.value.trim())}
      />
      {useBackup && <button onClick={submitBackup}>Verify</button>}
      {error && <p role="alert">{error}</p>}
      <button type="button" onClick={() => setUseBackup(!useBackup)}>
        {useBackup ? "Use authenticator app" : "Use a backup code"}
      </button>
    </main>
  );
}
