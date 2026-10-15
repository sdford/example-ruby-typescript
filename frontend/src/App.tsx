import { Navigate, Route, Routes } from "react-router-dom";
import { useAuth } from "./auth/AuthContext";
import LoginPage from "./pages/LoginPage";
import ProjectsPage from "./pages/ProjectsPage";
import ProjectPage from "./pages/ProjectPage";

export default function App() {
  const { user } = useAuth();

  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/projects" element={user ? <ProjectsPage /> : <Navigate to="/login" />} />
      <Route path="/projects/:id" element={user ? <ProjectPage /> : <Navigate to="/login" />} />
      <Route path="*" element={<Navigate to="/projects" />} />
    </Routes>
  );
}
