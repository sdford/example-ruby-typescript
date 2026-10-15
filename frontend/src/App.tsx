import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "./auth/AuthContext";
import LoginPage from "./pages/LoginPage";
import MfaChallengePage from "./pages/MfaChallengePage";
import ProjectsPage from "./pages/ProjectsPage";
import ProjectPage from "./pages/ProjectPage";
import SecurityPage from "./pages/SecurityPage";

export default function App() {
  const { user } = useAuth();

  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/login/mfa" element={<MfaChallengePage />} />
      <Route path="/projects" element={user ? <ProjectsPage /> : <Navigate to="/login" />} />
      <Route path="/projects/:id" element={user ? <ProjectPage /> : <Navigate to="/login" />} />
      <Route path="/settings/security" element={user ? <SecurityPage /> : <Navigate to="/login" />} />
      <Route path="*" element={<Navigate to="/projects" />} />
    </Routes>
  );
}
