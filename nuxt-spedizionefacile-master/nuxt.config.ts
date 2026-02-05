// https://nuxt.com/docs/api/configuration/nuxt-config

import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
	compatibilityDate: "2025-05-15",
	devtools: { enabled: true },
	app: {
		head: {
			link: [
				{
					rel: "stylesheet",
					href: "https://api.fontshare.com/css?f[]=general-sans@700&display=swap",
				},
			],
		},
	},
	vite: {
		plugins: [tailwindcss()],
	},
	/* image: {
		dir: "public/img",
		screens: {
			mobile: 375,
			tablet: 768,
			desktop: 1024,
			xl: 1280,
			"2xl": 1536,
		},
	}, */
	/* ssr: false, */
	/* ui: {
		fonts: false,
	}, */
	css: ["~/assets/css/main.css"],
	modules: ["@nuxt/image", "@nuxt/icon", "nuxt-auth-sanctum", "@pinia/nuxt", "@nuxt/ui", "@nuxt/fonts"],
	runtimeConfig: {
		public: {
			apiBase: (() => {
				const raw = process.env.NUXT_PUBLIC_API_BASE ?? "";
				if (!raw) {
					return "http://127.0.0.1:8000";
				}
				const raw = process.env.NUXT_PUBLIC_API_BASE ?? "http://localhost:8000";
				return raw.startsWith("http://") || raw.startsWith("https://") ? raw : `https://${raw}`;
			})(),
		},
	},
	sanctum: {
		baseUrl: (() => {
			const raw = process.env.NUXT_PUBLIC_API_BASE ?? "";
			if (!raw) {
				return "http://127.0.0.1:8000";
			}
			return raw.startsWith("http://") || raw.startsWith("https://") ? raw : `https://${raw}`;
		})(), // URL del tuo backend Laravel
			const raw = process.env.NUXT_PUBLIC_API_BASE ?? "http://localhost:8000";
			return raw.startsWith("http://") || raw.startsWith("https://") ? raw : `https://${raw}`;
		})(), // URL del tuo backend Laravel
			apiBase: process.env.NUXT_PUBLIC_API_BASE ?? "http://localhost:8000",
		},
	},
	sanctum: {
		baseUrl: process.env.NUXT_PUBLIC_API_BASE ?? "http://localhost:8000", // URL del tuo backend Laravel
		mode: "cookie",
		/* userStateKey: "sanctum.user.identity", */
		redirect: {
			/* keepRequestedRoute: false, */
			onLogin: "/account",
			onLogout: "/autenticazione",
			onAuthOnly: "/autenticazione",
			onGuestOnly: "/",
			/* onAuthOnly: "/auth/login",
			onGuestOnly: "/", */
		},
		endpoints: {
			csrf: "/sanctum/csrf-cookie",
			login: "/api/custom-login",
			logout: "/api/logout",
			user: "/api/user",
		},
		/* csrf: {
			cookie: "XSRF-TOKEN",
			header: "X-XSRF-TOKEN",
		},
		client: {
			retry: false,
			initialRequest: true,
		},
		globalMiddleware: {
			enabled: false,
			allow404WithoutAuth: true,
		}, */
		/* userStateKey: "sanctum.user.identity",
		redirectIfAuthenticated: false,
		redirectIfUnauthenticated: false,
		endpoints: {
			csrf: "/sanctum/csrf-cookie",
			login: "/login",
			logout: "/logout",
			user: "/api/user",
		},
		csrf: {
			cookie: "XSRF-TOKEN",
			header: "X-XSRF-TOKEN",
		},
		client: {
			retry: false,
			initialRequest: true,
		},
		redirect: {
			keepRequestedRoute: false,
			onLogin: "/",
			onLogout: "/",
			onAuthOnly: "/login",
			onGuestOnly: "/",
		},
		globalMiddleware: {
			enabled: false,
			allow404WithoutAuth: true,
		},
		logLevel: 3,
		appendPlugin: false, */
	},
});
