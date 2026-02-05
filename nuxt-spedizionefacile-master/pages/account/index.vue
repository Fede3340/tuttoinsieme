<script setup>
definePageMeta({
	middleware: ["sanctum:auth"],
});

const { user } = useSanctumAuth();

const accountPages = [
	{
		icon: "",
		title: "Amministrazione",
		description: "Crea una nuova spedizione o riprendi una bozza. Controlla stato, etichetta e tracking.",
		url: "/amministrazione",
		visible: true,
		visible: true ? user.value?.role === "Admin" : false,
	},
	{
		icon: "",
		title: "Spedizioni",
		description: "Crea una nuova spedizione o riprendi una bozza. Controlla stato, etichetta e tracking.",
		url: "/spedizioni",
		visible: true,
		/* visible: true ? user.value?.role === "Admin" : false,*/
	},
	{
		icon: "",
		title: "Carte e pagamenti",
		description: "Gestisci i metodi di pagamento e le preferenze. Visualizza lo storico dei pagamenti.",
		url: "/carte",
		visible: true,
	},
	{
		icon: "",
		title: "Indirizzi",
		description: "Salva mittenti e destinatari. Riutilizza indirizzi e rendi più veloce ogni ordine.",
		url: "/indirizzi",
		visible: true,
	},
	{
		icon: "",
		title: "Profilo e dati",
		description: "Aggiorna i tuoi dati personali e di fatturazione. Modifica email e password in sicurezza.",
		url: "/profilo",
		visible: true,
	},
	{
		icon: "",
		title: "Account Pro",
		description: "Richiedi il profilo Pro e sblocca vantaggi su volumi e funzioni avanzate.",
		url: "/account-pro",
		visible: true,
	},
	{
		icon: "",
		title: "Portafoglio",
		description: "Ricarica il portafoglio e paga più velocemente le spedizioni. Consulta saldo e movimenti.",
		url: "/",
		visible: true,
	},
	{
		icon: "",
		title: "Assistenza",
		description: "Apri un ticket o contattaci. Segui risposte e aggiornamenti sulle tue richieste.",
		url: "/",
		visible: true,
	},
	{
		icon: "",
		title: "Bonus",
		description: "Defalcate is most focused in helping you discover your most beautiful smile",
		url: "/",
		visible: true,
	},
	{
		icon: "",
		title: "Prelievi",
		description: "Richiedi l'accredito del saldo disponibile. Controlla stato e tempi di pagamento.",
		url: "/",
		visible: true,
	},
];

const filteredPages = accountPages.filter((page) => page.visible === true);
</script>

<template>
	<section class="desktop-xl:my-[157px] my-[50px] desktop:my-[131px]">
		<div class="my-container">
			<!-- <span v-if="isAuthenticated" class="font-bold text-[2rem]">Benvenuto {{ user?.name }}</span>

			<hr class="my-[20px]" />

			<div class="flex items-center justify-start gap-x-[20px]">
				<NuxtLink to="/dashboard/profilo" class="block border border-gray-400 rounded-[10px] p-[10px]">Informazioni Profilo</NuxtLink>

				<NuxtLink to="/dashboard/indirizzi" class="block border border-gray-400 rounded-[10px] p-[10px]">I tuoi Indirizzi</NuxtLink>

				<NuxtLink to="/dashboard/carte" class="block border border-gray-400 rounded-[10px] p-[10px]">Le tue carte salvate</NuxtLink>

				<NuxtLink v-if="user?.role === 'Admin'" to="/dashboard/admin" class="block border border-gray-400 rounded-[10px] p-[10px]">Admin</NuxtLink>
			</div>

			<hr class="my-[20px]" /> -->

			<ul class="flex items-start justify-start flex-wrap gap-[40px] desktop:gap-x-[85px] desktop:gap-y-[96px]">
				<li
					v-for="(page, pageIndex) in filteredPages"
					:key="pageIndex"
					class="basis-full account-pages:basis-[calc(50%-40px)] desktop:basis-[calc(100%/3-57px)] h-[180px] desktop-xl:h-[278px] desktop:h-[270px] bg-[#E4E4E4] rounded-[20px] text-center font-montserrat">
					<NuxtLink :to="`/account${page.url}`" class="flex flex-col items-center justify-center size-full rounded-[20px] desktop:px-[20px] px-[40px] desktop-xl:px-[50px]">
						<h2 class="text-[1.125rem] text-[#252B42] font-bold desktop-xl:text-[1.5rem] tracking-[0.1px]">
							{{ page.title }}
						</h2>
						<p class="text-[#737373] text-[0.6875rem] desktop-xl:text-[0.875rem] tracking-[0.2px] leading-[20px] mt-[15px]">
							{{ page.description }}
						</p>
					</NuxtLink>
				</li>
			</ul>
		</div>
	</section>
</template>
