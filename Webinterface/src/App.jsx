import React, { useState } from 'react';
import {
  Download,
  ShieldCheck,
  BellRing,
  CreditCard,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  Building2,
  X,
} from 'lucide-react';

// Replace the `image` paths with your screenshots in `/public/screens/`
const APP_SCREENS = [
  { id: 'registration', title: 'Quick tenant onboarding', subtitle: 'Floor and room allocation during signup', tag: 'Tenant portal', image: '/screens/registration.png', fallbackType: 'registration' },
  { id: 'admin-login', title: 'Secure admin access', subtitle: 'Role-based sign-in for admins and owners', tag: 'Security', image: '/screens/admin-login.png', fallbackType: 'admin-login' },
  { id: 'home', title: 'Your home, managed simply', subtitle: 'Rent, reminders and support in one place', tag: 'Home', image: '/screens/home.png', fallbackType: 'home' },
  { id: 'admin-panel', title: 'Admin dashboard', subtitle: 'Live tenant status, queries and floor setup', tag: 'Management', image: '/screens/admin-panel.png', fallbackType: 'admin-panel' },
  { id: 'rent-details', title: 'Automatic late fees', subtitle: 'Overdue tracking and fee calculation', tag: 'Automation', image: '/screens/rent-details.png', fallbackType: 'rent-details' },
];

const FEATURES = [
  { icon: ShieldCheck, title: 'Role-based security', description: 'Admin and owner portals stay separate from tenant views, protected by encrypted sign-in.' },
  { icon: CreditCard, title: 'Rent and query tracking', description: 'See monthly rent status, room allocations and repair requests from a single dashboard.' },
  { icon: BellRing, title: 'Reminders and late fees', description: 'Tenants get a notification before the due date, and overdue balances update automatically.' },
];

function ScreenFallback({ type }) {
  const bar = 'bg-[#0D385B] text-white px-3.5 py-3 pt-7 text-xs font-semibold';
  const field = 'bg-white border border-slate-200 rounded-md px-2 py-1.5 text-[8px] text-slate-400';

  if (type === 'home') {
    return (
      <div className="h-full w-full bg-[#FAF6EE] flex flex-col text-left select-none">
        <div className="bg-[#0D385B] text-white p-4 pt-7 rounded-b-3xl">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-7 h-7 rounded-full bg-[#E3A82B] flex items-center justify-center">
              <Building2 className="w-4 h-4 text-[#0D385B]" />
            </div>
            <div>
              <p className="text-xs font-semibold leading-tight">Gupta Capitals</p>
              <p className="text-[9px] text-slate-300">Rent management</p>
            </div>
          </div>
          <p className="font-display text-lg leading-snug">Your home, managed simply.</p>
          <p className="text-[9px] text-slate-300 mt-1">Pay rent, raise requests and stay updated.</p>
        </div>
        <div className="p-3 flex-1 flex flex-col justify-between">
          <div className="bg-white rounded-2xl p-3 space-y-2 border border-slate-100">
            {['Manage your home', 'Pay rent online', 'Get reminders', 'Raise complaints'].map((item) => (
              <div key={item} className="flex items-center gap-2 border-b last:border-none border-slate-100 pb-1.5 last:pb-0">
                <span className="w-1.5 h-1.5 rounded-full bg-[#E3A82B]" />
                <span className="text-[10px] font-semibold">{item}</span>
              </div>
            ))}
          </div>
          <div className="space-y-1.5">
            <div className="w-full py-2 bg-[#0D385B] text-white text-[10px] font-semibold rounded-full text-center">Log in</div>
            <div className="w-full py-2 border border-[#0D385B]/30 text-[10px] font-semibold rounded-full text-center">Create account</div>
          </div>
        </div>
      </div>
    );
  }

  if (type === 'admin-login') {
    return (
      <div className="h-full w-full bg-[#0D385B] p-4 pt-8 flex flex-col items-center justify-center text-center select-none">
        <div className="w-11 h-11 rounded-full bg-[#E3A82B] flex items-center justify-center mb-3">
          <ShieldCheck className="w-5 h-5 text-[#0D385B]" />
        </div>
        <p className="font-display text-white text-base">Admin portal</p>
        <p className="text-slate-300 text-[9px] mb-4">Manage tenants and payments</p>
        <div className="w-full bg-[#FAF6EE] rounded-2xl p-3 text-left space-y-2.5">
          <div><p className="text-[9px] font-semibold mb-1">Username</p><div className={field}>Enter username</div></div>
          <div><p className="text-[9px] font-semibold mb-1">Password</p><div className={field}>••••••••</div></div>
          <div className="w-full py-2 bg-[#0D385B] text-white text-[10px] font-semibold rounded-full text-center">Log in</div>
        </div>
      </div>
    );
  }

  if (type === 'admin-panel') {
    return (
      <div className="h-full w-full bg-[#FAF6EE] flex flex-col text-left select-none">
        <div className={bar}>Admin panel</div>
        <div className="p-3 space-y-2.5 flex-1">
          <div className="bg-[#0D385B] rounded-2xl p-3 text-white flex items-center gap-3">
            <div className="font-display text-[#E3A82B] text-2xl">7</div>
            <div className="text-[10px] text-slate-300">Active tenants</div>
          </div>
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-[#E3A82B] text-[#0D385B] text-[10px] font-semibold py-1.5 rounded-full text-center">Queries</div>
            <div className="bg-[#0D385B] text-white text-[10px] font-semibold py-1.5 rounded-full text-center">Floor setup</div>
          </div>
          {['Tausif Khan', 'Sahil', 'Akash Soni', 'Priyansh Sao'].map((name, i) => (
            <div key={name} className="bg-white p-2 rounded-xl border border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 rounded-full bg-[#0D385B] text-white text-[10px] font-semibold flex items-center justify-center">{name[0]}</div>
                <div>
                  <p className="text-[10px] font-semibold">{name}</p>
                  <p className="text-[8px] text-slate-400">Room 10{i + 1}</p>
                </div>
              </div>
              <span className="text-[8px] font-semibold text-amber-600 border border-amber-400 px-1.5 py-0.5 rounded-full">Pending</span>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (type === 'rent-details') {
    const row = (l, v, c = '') => (
      <div className="flex justify-between text-[9px]">
        <span className="text-slate-400">{l}</span>
        <span className={`font-semibold ${c}`}>{v}</span>
      </div>
    );
    return (
      <div className="h-full w-full bg-[#FAF6EE] flex flex-col text-left select-none">
        <div className={bar}>Rent ledger</div>
        <div className="p-3 space-y-2.5 flex-1">
          <div className="bg-white rounded-2xl p-3 border border-slate-100 space-y-1.5">
            <p className="text-[10px] font-semibold border-b pb-1">Details</p>
            {row('Room type', 'Residential')}
            {row('Status', 'Pending', 'text-amber-600')}
          </div>
          <div className="bg-white rounded-2xl p-3 border border-slate-100 space-y-1.5">
            <p className="text-[10px] font-semibold border-b pb-1">Rent and late fee</p>
            {row('Monthly rent', '₹8,000')}
            {row('Late fee', '₹1,410', 'text-red-600')}
            {row('Total due', '₹9,410')}
            <div className="mt-2 bg-red-50 border border-red-200 text-red-600 text-[9px] font-semibold py-1.5 px-2 rounded-full text-center">
              Overdue. Total due ₹9,410
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full w-full bg-[#FAF6EE] flex flex-col text-left select-none">
      <div className={bar}>New registration</div>
      <div className="p-3 space-y-2 flex-1">
        <p className="font-display text-sm">Create your account</p>
        {['Full name', 'Mobile number', 'Floor', 'Room / unit', 'Password'].map((label) => (
          <div key={label}>
            <p className="text-[8px] font-semibold mb-0.5">{label}</p>
            <div className={field}>Enter {label.toLowerCase()}</div>
          </div>
        ))}
        <div className="w-full py-2 bg-[#E3A82B] text-[#0D385B] text-[9px] font-semibold rounded-full text-center mt-2">Register</div>
      </div>
    </div>
  );
}

export default function App() {
  const [activeIndex, setActiveIndex] = useState(2);
  const [lightboxScreen, setLightboxScreen] = useState(null);
  const [imgErrors, setImgErrors] = useState({});
  const [downloadToast, setDownloadToast] = useState(false);

  const handleApkDownload = () => {
    setDownloadToast(true);
    setTimeout(() => setDownloadToast(false), 4000);
  };
  const handleNext = () => setActiveIndex((p) => (p + 1) % APP_SCREENS.length);
  const handlePrev = () => setActiveIndex((p) => (p - 1 + APP_SCREENS.length) % APP_SCREENS.length);

  const apkProps = {
    href: '/gupta-capitals-v1.0.apk',
    download: 'GuptaCapitals_v1.0.apk',
    onClick: handleApkDownload,
  };

  return (
    <div className="min-h-screen bg-[#FAF6EE] text-[#0D385B] selection:bg-[#E3A82B]/30 overflow-x-hidden">
      {downloadToast && (
        <div role="status" className="fixed bottom-6 right-6 z-50 flex items-center gap-3 bg-[#0D385B] text-white px-5 py-3.5 rounded-full shadow-xl">
          <CheckCircle2 className="w-5 h-5 text-[#E3A82B]" />
          <div className="text-sm">
            <p className="font-semibold">Downloading GuptaCapitals_v1.0.apk</p>
            <p className="text-xs text-slate-300">Check your downloads folder</p>
          </div>
        </div>
      )}

      {/* Navbar */}
      <header className="sticky top-0 z-40 backdrop-blur-md bg-[#FAF6EE]/80">
        <div className="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-[#0D385B] flex items-center justify-center">
              <Building2 className="w-4 h-4 text-[#E3A82B]" />
            </div>
            <span className="font-display text-xl font-medium">Gupta Capitals</span>
          </div>

          <nav className="hidden md:flex items-center gap-9 text-sm font-medium text-[#0D385B]/70">
            <a href="#showcase" className="hover:text-[#0D385B] transition-colors">Screens</a>
            <a href="#features" className="hover:text-[#0D385B] transition-colors">Features</a>
          </nav>

          <a {...apkProps} className="btn-small">
            <Download className="w-4 h-4" />
            Download APK
          </a>
        </div>
      </header>

      {/* Hero + phone fan */}
      <section id="showcase" className="pt-16 sm:pt-24 pb-20 px-4 sm:px-6">
        <div className="max-w-3xl mx-auto text-center">
          <h1 className="font-display text-4xl sm:text-6xl font-normal leading-[1.08] text-[#0D385B]">
            Tenant management, made calm.
          </h1>
          <p className="mt-6 text-base sm:text-lg text-[#0D385B]/65 max-w-xl mx-auto leading-relaxed">
            One app for rent tracking, tenant requests and automatic late fees, with separate
            access for owners and tenants.
          </p>

          <div className="mt-10 flex flex-col items-center gap-3">
            <a {...apkProps} className="btn-primary">
              Download for Android
              <span className="btn-dot"><Download className="w-4 h-4" /></span>
            </a>
            <p className="text-xs text-[#0D385B]/50">Version 1.0 · Android 8.0 and above</p>
          </div>
        </div>

        <div className="relative max-w-6xl mx-auto mt-16 h-[480px] sm:h-[540px] flex items-center justify-center">
          <button onClick={handlePrev} aria-label="Previous screen" className="absolute left-2 sm:left-6 z-30 p-3 rounded-full border border-[#0D385B]/15 bg-[#FAF6EE] hover:bg-[#0D385B] hover:text-white transition-colors">
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button onClick={handleNext} aria-label="Next screen" className="absolute right-2 sm:right-6 z-30 p-3 rounded-full border border-[#0D385B]/15 bg-[#FAF6EE] hover:bg-[#0D385B] hover:text-white transition-colors">
            <ChevronRight className="w-5 h-5" />
          </button>

          <div className="relative w-full h-full flex items-center justify-center">
            {APP_SCREENS.map((screen, index) => {
              let offset = index - activeIndex;
              if (offset > 2) offset -= APP_SCREENS.length;
              if (offset < -2) offset += APP_SCREENS.length;

              const absOffset = Math.abs(offset);
              const isCenter = offset === 0;
              const style = {
                transform: `translateX(${offset * 175}px) translateY(${absOffset * 18}px) scale(${isCenter ? 1.04 : absOffset === 1 ? 0.92 : 0.8}) rotate(${offset * 2}deg)`,
                zIndex: 30 - absOffset * 10,
                opacity: absOffset === 2 ? 0.7 : 1,
              };

              return (
                <button
                  key={screen.id}
                  type="button"
                  aria-label={isCenter ? `Enlarge ${screen.title}` : `Show ${screen.title}`}
                  onClick={() => (isCenter ? setLightboxScreen(screen) : setActiveIndex(index))}
                  style={style}
                  className="absolute cursor-pointer transition-all duration-500 ease-out"
                >
                  <div className={`w-[225px] sm:w-[245px] h-[455px] sm:h-[495px] rounded-[38px] p-2 bg-[#0f1720] transition-shadow duration-500 ${isCenter ? 'shadow-[0_30px_60px_-20px_rgba(13,56,91,0.45)]' : 'shadow-[0_16px_32px_-16px_rgba(13,56,91,0.3)]'}`}>
                    <div className="relative w-full h-full rounded-[30px] overflow-hidden bg-[#FAF6EE]">
                      <div className="absolute top-2 left-1/2 -translate-x-1/2 w-2.5 h-2.5 rounded-full bg-black z-20" />
                      {!imgErrors[screen.id] ? (
                        <img
                          src={screen.image}
                          alt={screen.title}
                          onError={() => setImgErrors((p) => ({ ...p, [screen.id]: true }))}
                          className="w-full h-full object-cover object-top"
                        />
                      ) : (
                        <ScreenFallback type={screen.fallbackType} />
                      )}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        <div className="max-w-md mx-auto text-center mt-8">
          <h3 className="font-display text-2xl">{APP_SCREENS[activeIndex].title}</h3>
          <p className="text-sm text-[#0D385B]/60 mt-1.5">{APP_SCREENS[activeIndex].subtitle}</p>
          <div className="flex items-center justify-center gap-2 mt-5">
            {APP_SCREENS.map((s, idx) => (
              <button
                key={s.id}
                onClick={() => setActiveIndex(idx)}
                aria-label={`Select ${s.title}`}
                className={`h-1.5 rounded-full transition-all duration-300 ${idx === activeIndex ? 'w-8 bg-[#0D385B]' : 'w-1.5 bg-[#0D385B]/25 hover:bg-[#0D385B]/50'}`}
              />
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-24 px-6 bg-white">
        <div className="max-w-5xl mx-auto">
          <h2 className="font-display text-3xl sm:text-4xl max-w-lg">
            Built for owners and tenants alike.
          </h2>
          <div className="mt-14 grid md:grid-cols-3 gap-x-12 gap-y-12">
            {FEATURES.map((feat) => {
              const Icon = feat.icon;
              return (
                <div key={feat.title} className="border-t border-[#0D385B]/15 pt-6">
                  <Icon className="w-6 h-6 text-[#E3A82B] mb-5" strokeWidth={1.5} />
                  <h3 className="font-display text-xl mb-2">{feat.title}</h3>
                  <p className="text-sm leading-relaxed text-[#0D385B]/65">{feat.description}</p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Download banner */}
      <section className="py-24 px-6">
        <div className="max-w-4xl mx-auto bg-[#0D385B] rounded-[40px] px-8 py-16 sm:px-16 text-center text-white">
          <h2 className="font-display text-3xl sm:text-4xl leading-tight max-w-xl mx-auto">
            Try Gupta Capitals on your phone.
          </h2>
          <p className="text-slate-300 mt-4 text-sm sm:text-base max-w-md mx-auto">
            Install the APK to explore tenant sign-up, admin controls and late-fee calculation.
          </p>
          <a {...apkProps} className="btn-gold mt-9">
            Download APK
            <span className="btn-dot"><Download className="w-4 h-4" /></span>
          </a>
        </div>
      </section>

      <footer className="py-10 px-6 text-center text-xs text-[#0D385B]/50">
        <p>© {new Date().getFullYear()} Gupta Capitals. Built with Flutter, Node.js and MongoDB.</p>
      </footer>

      {/* Lightbox */}
      {lightboxScreen && (
        <div
          onClick={() => setLightboxScreen(null)}
          className="fixed inset-0 z-50 bg-[#0D385B]/70 backdrop-blur-sm flex items-center justify-center p-4"
        >
          <div
            role="dialog"
            aria-label={lightboxScreen.title}
            onClick={(e) => e.stopPropagation()}
            className="relative bg-[#FAF6EE] rounded-[32px] p-8 max-w-sm w-full shadow-2xl text-center"
          >
            <button
              onClick={() => setLightboxScreen(null)}
              aria-label="Close"
              className="absolute top-4 right-4 p-2 rounded-full border border-[#0D385B]/15 hover:bg-[#0D385B] hover:text-white transition-colors"
            >
              <X className="w-4 h-4" />
            </button>

            <h3 className="font-display text-xl mb-5 px-6">{lightboxScreen.title}</h3>

            <div className="w-[240px] h-[490px] mx-auto rounded-[38px] p-2 bg-[#0f1720] shadow-xl">
              <div className="w-full h-full rounded-[30px] overflow-hidden bg-[#FAF6EE]">
                {!imgErrors[lightboxScreen.id] ? (
                  <img src={lightboxScreen.image} alt={lightboxScreen.title} className="w-full h-full object-cover object-top" />
                ) : (
                  <ScreenFallback type={lightboxScreen.fallbackType} />
                )}
              </div>
            </div>

            <p className="text-xs text-[#0D385B]/60 mt-5">{lightboxScreen.subtitle}</p>
          </div>
        </div>
      )}
    </div>
  );
}
// import { useState } from 'react'
// import heroImg from './assets/hero.png'
// import reactLogo from './assets/react.svg'
// import viteLogo from './assets/vite.svg'
// import './App.css'

// function App() {
//   const [count, setCount] = useState(0)

//   return (
//     <>
//       <section id="center">
//         <div className="hero">
//           <img src={heroImg} className="base" width="170" height="179" alt="" />
//           <img src={reactLogo} className="framework" alt="React logo" />
//           <img src={viteLogo} className="vite" alt="Vite logo" />
//         </div>
//         <div>
//           <h1>Get started</h1>
//           <p>
//             Edit <code>src/App.jsx</code> and save to test <code>HMR</code>
//           </p>
//         </div>
//         <button
//           type="button"
//           className="counter"
//           onClick={() => setCount((count) => count + 1)}
//         >
//           Count is {count}
//         </button>
//       </section>

//       <div className="ticks"></div>

//       <section id="next-steps">
//         <div id="docs">
//           <svg className="icon" role="presentation" aria-hidden="true">
//             <use href="/icons.svg#documentation-icon"></use>
//           </svg>
//           <h2>Documentation</h2>
//           <p>Your questions, answered</p>
//           <ul>
//             <li>
//               <a href="https://vite.dev/" target="_blank">
//                 <img className="logo" src={viteLogo} alt="" />
//                 Explore Vite
//               </a>
//             </li>
//             <li>
//               <a href="https://react.dev/" target="_blank">
//                 <img className="button-icon" src={reactLogo} alt="" />
//                 Learn more
//               </a>
//             </li>
//           </ul>
//         </div>
//         <div id="social">
//           <svg className="icon" role="presentation" aria-hidden="true">
//             <use href="/icons.svg#social-icon"></use>
//           </svg>
//           <h2>Connect with us</h2>
//           <p>Join the Vite community</p>
//           <ul>
//             <li>
//               <a href="https://github.com/vitejs/vite" target="_blank">
//                 <svg
//                   className="button-icon"
//                   role="presentation"
//                   aria-hidden="true"
//                 >
//                   <use href="/icons.svg#github-icon"></use>
//                 </svg>
//                 GitHub
//               </a>
//             </li>
//             <li>
//               <a href="https://chat.vite.dev/" target="_blank">
//                 <svg
//                   className="button-icon"
//                   role="presentation"
//                   aria-hidden="true"
//                 >
//                   <use href="/icons.svg#discord-icon"></use>
//                 </svg>
//                 Discord
//               </a>
//             </li>
//             <li>
//               <a href="https://x.com/vite_js" target="_blank">
//                 <svg
//                   className="button-icon"
//                   role="presentation"
//                   aria-hidden="true"
//                 >
//                   <use href="/icons.svg#x-icon"></use>
//                 </svg>
//                 X.com
//               </a>
//             </li>
//             <li>
//               <a href="https://bsky.app/profile/vite.dev" target="_blank">
//                 <svg
//                   className="button-icon"
//                   role="presentation"
//                   aria-hidden="true"
//                 >
//                   <use href="/icons.svg#bluesky-icon"></use>
//                 </svg>
//                 Bluesky
//               </a>
//             </li>
//           </ul>
//         </div>
//       </section>

//       <div className="ticks"></div>
//       <section id="spacer"></section>
//     </>
//   )
// }

// export default App
