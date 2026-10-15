export type Role = "viewer" | "editor" | "admin";

export interface User {
  id: number;
  name: string;
  email: string;
  role: Role;
  mfa_enabled: boolean;
}

export interface MfaStatusRow {
  user_id: number;
  name: string;
  email: string;
  role: Role;
  mfa_enabled: boolean;
}

export interface Measurement {
  kind: string;
  value: number;
  unit: string;
}

export interface Project {
  id: number;
  name: string;
  address: string;
  notes: string | null;
  status: "scanning" | "processing" | "ready";
  updated_at: string;
  measurements?: Measurement[];
}
