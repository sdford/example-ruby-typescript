import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from "react";
import { apiFetch, setAuthToken } from "../api/client";
import type { User } from "../types";

type LoginResponse = { token: string; user: User } | { mfa_required: true; user_id: number };

export type LoginResult = { mfaRequired: false } | { mfaRequired: true; userId: number };

interface AuthState {
  user: User | null;
  login: (email: string, password: string) => Promise<LoginResult>;
  completeMfa: (userId: number, code: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthState | null>(null);

// Token lives in memory only, so an XSS cannot read it from storage.
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const login = useCallback(async (email: string, password: string): Promise<LoginResult> => {
    const res = await apiFetch<LoginResponse>("/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
    if ("mfa_required" in res) return { mfaRequired: true, userId: res.user_id };

    setAuthToken(res.token);
    setUser(res.user);
    return { mfaRequired: false };
  }, []);

  const completeMfa = useCallback(async (userId: number, code: string) => {
    const res = await apiFetch<{ token: string; user: User }>("/login/mfa", {
      method: "POST",
      body: JSON.stringify({ user_id: userId, code }),
    });
    setAuthToken(res.token);
    setUser(res.user);
  }, []);

  const logout = useCallback(() => {
    setAuthToken(null);
    setUser(null);
  }, []);

  const value = useMemo(() => ({ user, login, completeMfa, logout }), [user, login, completeMfa, logout]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used inside AuthProvider");
  return ctx;
}
