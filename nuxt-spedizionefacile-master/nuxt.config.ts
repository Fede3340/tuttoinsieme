// https://nuxt.com/docs/api/configuration/nuxt-config

import tailwindcss from "@tailwindcss/vite";

const resolveApiBase = (): string => {
	const raw = process.env.NUXT_PUBLIC_API_BASE ?? "";
	if (!raw) {
		return "http://127.0.0.1:8787";
	}

	if (raw.startsWith("http://") || raw.startsWith("https://")) {
		return raw;
	}

	return "https://" + raw;
};

const apiBase = resolveApiBase();

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
			apiBase,
		},
	},
	sanctum: {
		baseUrl: apiBase,
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
