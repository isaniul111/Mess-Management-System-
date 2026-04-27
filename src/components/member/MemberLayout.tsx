import { useState, useEffect, ReactNode } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../../context/AuthContext';
import {
  LayoutDashboard,
  UtensilsCrossed,
  Bell,
  User,
  LogOut,
  Users,
  Menu,
  X,
  Sun,
  Moon,
} from 'lucide-react';

type MemberLayoutProps = {
  children: ReactNode;
};

export default function MemberLayout({ children }: MemberLayoutProps) {
  const navigate = useNavigate();
  const location = useLocation();
  const { profile, signOut } = useAuth();

  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const [theme, setTheme] = useState<'dark' | 'light'>(() => {
    return (localStorage.getItem('memberTheme') as 'dark' | 'light') || 'dark';
  });

  const isDark = theme === 'dark';

  useEffect(() => {
    localStorage.setItem('memberTheme', theme);
  }, [theme]);

  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [location.pathname]);

  const toggleTheme = () => {
    setTheme(prev => (prev === 'dark' ? 'light' : 'dark'));
  };

  // 🔴 FIX: Removed '/member' from the paths to match App.tsx routes
  const menuItems = [
    { icon: LayoutDashboard, label: 'Dashboard', path: '/dashboard' },
    { icon: UtensilsCrossed, label: 'Meals', path: '/meals' },
    { icon: Bell, label: 'Notices', path: '/notices' },
    { icon: User, label: 'Profile', path: '/profile' },
  ];

  const handleSignOut = async () => {
    await signOut();
    navigate('/login');
  };

  // --------------------------------------------------------
  // REUSABLE CLEAN SIDEBAR CONTENT
  // --------------------------------------------------------
  const SidebarContent = () => (
    <div className="flex flex-col h-full overflow-y-auto overflow-x-hidden">
      
      {/* 1. Header / Logo Area */}
      <div className={`flex items-center justify-between px-6 py-7 border-b ${isDark ? 'border-white/[0.05]' : 'border-slate-200/60'}`}>
        <div className="flex items-center gap-3.5">
          <div className={`p-2.5 rounded-xl flex items-center justify-center ${isDark ? 'bg-indigo-500/10 text-indigo-400' : 'bg-indigo-50 text-indigo-600'}`}>
            <Users size={22} strokeWidth={2.5} />
          </div>
          <div className="min-w-0">
            <h2 className={`text-base font-bold tracking-tight truncate ${isDark ? 'text-white' : 'text-slate-900'}`}>
              Resident Portal
            </h2>
            <p className={`text-[10px] font-bold tracking-widest uppercase ${isDark ? 'text-indigo-400/80' : 'text-indigo-600/80'}`}>
              Member Access
            </p>
          </div>
        </div>

        {/* Mobile Close Button (Inside Sidebar) */}
        <button
          onClick={() => setIsMobileMenuOpen(false)}
          className={`lg:hidden p-2 rounded-xl transition-all duration-200 ${
            isDark ? 'bg-white/5 text-slate-400 hover:text-white' : 'bg-slate-100 text-slate-500 hover:text-slate-900'
          }`}
        >
          <X size={18} />
        </button>
      </div>

      {/* 2. Main Navigation Links */}
      <div className="px-4 py-8 space-y-1.5">
        <p className={`px-3 text-[10px] font-extrabold uppercase tracking-widest mb-4 ${isDark ? 'text-slate-600' : 'text-slate-400'}`}>
          Main Menu
        </p>
        
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname.includes(item.path);

          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`group flex items-center w-full px-3 py-3 rounded-xl transition-all duration-200 text-sm ${
                isActive
                  ? isDark 
                    ? 'bg-indigo-500/10 text-indigo-300 font-bold' 
                    : 'bg-indigo-50 text-indigo-700 font-bold shadow-sm'
                  : isDark
                    ? 'text-slate-400 font-medium hover:bg-white/[0.04] hover:text-slate-200'
                    : 'text-slate-500 font-medium hover:bg-slate-50 hover:text-slate-900'
              }`}
            >
              <div className="flex items-center gap-3.5">
                <Icon 
                  size={18} 
                  strokeWidth={isActive ? 2.5 : 2} 
                  className={`transition-transform duration-200 ${isActive ? 'scale-110' : 'group-hover:scale-110'} ${
                    isActive ? (isDark ? 'text-indigo-400' : 'text-indigo-600') : 'text-inherit'
                  }`} 
                />
                {item.label}
              </div>
              
              {isActive && (
                <div className={`ml-auto w-1.5 h-1.5 rounded-full ${isDark ? 'bg-indigo-400' : 'bg-indigo-600'}`} />
              )}
            </button>
          );
        })}
      </div>

      {/* 3. Integrated Theme Switcher & Footer */}
      
      
    </div>
  );
}