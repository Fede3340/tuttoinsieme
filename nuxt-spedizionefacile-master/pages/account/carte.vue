<script setup>
import { loadStripe } from "@stripe/stripe-js";

definePageMeta({
	middleware: ["sanctum:auth"],
});

const { refreshIdentity } = useSanctumAuth();

const stripePromise = loadStripe("pk_test_51RNEIjQm1dxS70cRuVsAvE6AXUo9WHTuSWZezqOLImfxG5G3hPTw1t5BwPjP44hvCL0nqxQZWdAxQwjj58yiHmZ100wjOJhkhm"); // tua chiave pubblicabile

const stripe = await stripePromise;

const cardNumber = ref(null);
const cardExpiry = ref(null);
const cardCvc = ref(null);
const clientSecret = ref(null);
const elements = ref(null);

/* const { data: client_secret, refresh: myRefresh } = useSanctumFetch("/api/stripe/create-setup-intent", {
	method: "POST",
}); */

const loadSetupIntent = async () => {
	const { data, error } = await useSanctumFetch("/api/stripe/create-setup-intent", {
		method: "POST",
	});

	if (!error.value) {
		clientSecret.value = data.value.client_secret;
	}
};

const errorMessage = ref(null);

const cardHolderName = ref("");

const showFormPayments = ref(false);

const textMessage = ref("");

const { data: payments, status, refresh } = useSanctumFetch("/api/stripe/payment-methods");

const handleAddCard = async () => {
	if (!clientSecret.value) {
		console.error("Client secret mancante.");
		return;
	}

	textMessage.value = "Aggiunta in corso...";

	errorMessage.value = null;

	try {
		const stripe = await stripePromise;

		// Conferma il SetupIntent con la carta inserita
		const { setupIntent, error } = await stripe.confirmCardSetup(clientSecret.value, {
			payment_method: {
				card: cardNumber.value,
				billing_details: {
					name: cardHolderName.value,
				},
			},
		});

		// Controlla prima eventuali errori
		if (error) {
			console.error("Errore nel salvataggio della carta:", error);

			errorMessage.value = error.message;

			textMessage.value = null;
		}

		// A questo punto setupIntent.payment_method è disponibile
		if (!setupIntent?.payment_method) {
			console.error("Payment method non trovato nel SetupIntent");
			return;
		}

		// Chiamata al server per impostare la carta come predefinita
		const { data, error: serverError } = await useSanctumFetch("api/stripe/set-default-payment-method", {
			method: "POST",
			body: { payment_method: setupIntent.payment_method },
		});

		if (serverError?.value) {
			console.error("Errore server:", serverError.value);
			return;
		}

		console.log("Carta impostata come predefinita:", data.value);

		await refresh();

		await refreshIdentity();

		textMessage.value = "";
		showFormPayments.value = false;

		console.log("Carta salvata correttamente:", setupIntent);
	} catch (err) {
		console.error("Errore imprevisto:", err);
	}
};

const setDefault = async (pmId) => {
	textMessage.value = "Modifica in corso...";

	try {
		const { data } = await useSanctumFetch("api/stripe/change-default-payment-method", {
			method: "POST",
			body: { payment_method_id: pmId },
		});
		if (data.value?.success) {
			// aggiorna UI: es. defaultId.value = pmId

			textMessage.value = null;

			await refresh();

			console.log("Default impostato:", data.value.default);
		} else {
			console.error("Errore impostazione default", data.value);
		}
	} catch (e) {
		console.error("Errore:", e);
	}
};

const open = ref(false);

const deleteCard = async (pmId) => {
	/* textMessage.value = "Eliminazione in corso..."; */

	try {
		const { data } = await useSanctumFetch("api/stripe/delete-card", {
			method: "DELETE",
			body: { payment_method_id: pmId },
		});

		if (data.value?.success) {
			await refresh();
			console.log("Carta eliminata con successo");
			open.value = false;
		} else {
			console.error("Errore eliminazione carta");
		}
	} catch (error) {
		console.error("Errore imprevisto:", err);
	} /*  finally {
		textMessage.value = "";
	} */
};

const initStripe = async (client_secret) => {
	if (!client_secret) return;

	const stripe = await stripePromise;

	await nextTick();

	try {
		elements = stripe.elements({ clientSecret: client_secret });

		const style = {
			base: {
				color: "#aaaaaa", // colore del testo
				fontFamily: "Inter, sans-serif",
				fontSize: "15px",
				"::placeholder": {
					color: "#aaaaaa", // colore del placeholder
				},
			},
			invalid: {
				color: "#ff4d4f", // colore in caso di errore
			},
		};

		cardNumber.value = elements.create("cardNumber", { style, placeholder: "Numero carta" });
		cardNumber.value.mount("#card-number");

		cardExpiry.value = elements.create("cardExpiry", { style });
		cardExpiry.value.mount("#card-expiry");

		cardCvc.value = elements.create("cardCvc", { style, placeholder: "123" });
		cardCvc.value.mount("#card-cvc");
	} catch (err) {
		console.error("Errore:", err);
	}
};

/* const { data: client_secret, error } = useSanctumFetch("/api/stripe/create-setup-intent", {
	method: "POST",
}); */

const togglePaymentForm = async () => {
	if (showFormPayments.value) {
		// Chiudi form: smonta elementi
		cardHolderName.value = null;
		cardNumber.value?.unmount();
		cardExpiry.value?.unmount();
		cardCvc.value?.unmount();
		cardNumber.value = null;
		cardExpiry.value = null;
		cardCvc.value = null;
		clientSecret.value = null;
		showFormPayments.value = false;
		elements.value = null;
	} else {
		clientSecret.value = null;
		// Apri form: crea nuovo SetupIntent
		const { data, execute } = await useSanctumFetch("/api/stripe/create-setup-intent", {
			method: "POST",
			/* lazy: true, */ // non esegue automaticamente
		});

		execute();

		clientSecret.value = data.value.client_secret;

		showFormPayments.value = true;

		await nextTick();

		elements.value = stripe.elements({ clientSecret: clientSecret.value });

		const style = {
			base: {
				color: "#aaaaaa",
				fontFamily: "Inter, sans-serif",
				fontSize: "15px",
				"::placeholder": { color: "#aaaaaa" },
			},
			invalid: { color: "#ff4d4f" },
		};

		cardNumber.value = elements.value.create("cardNumber", { style, placeholder: "Numero carta" });
		cardNumber.value.mount("#card-number");

		cardExpiry.value = elements.value.create("cardExpiry", { style });
		cardExpiry.value.mount("#card-expiry");

		cardCvc.value = elements.value.create("cardCvc", { style, placeholder: "123" });
		cardCvc.value.mount("#card-cvc");
	}
};

const addCartForm = () => {
	showFormPayments.value = true;

	cardNumber.value = null;
	cardExpiry.value = null;
	cardCvc.value = null;
};

const getTitle = computed(() => {
	if (!showFormPayments.value) {
		return "Le tue carte";
	} else {
		return "Aggiungi carta";
	}
});
</script>

<template>
	<section class="min-h-[400px] py-[80px]">
		<div class="my-container">
			<div class="mb-[20px]">
				<NuxtLink to="/account" class="hover:underline">Il tuo account</NuxtLink>
				›
				<span :class="{ 'font-bold': !showFormPayments }">Le tue carte</span>

				<span v-if="showFormPayments">
					›
					<span class="font-bold">Aggiungi carta</span>
				</span>
			</div>

			<h1 class="font-bold text-[2rem]">{{ getTitle }}</h1>

			<div v-if="payments && payments.data">
				<div v-if="!showFormPayments">
					<ul v-if="payments.data.length > 0">
						<li v-for="(payment, index) in payments.data" :key="index" class="mb-[30px] last:mb-0">
							<div>{{ payment.brand }}</div>
							<div>Nome: {{ payment.holder_name }}</div>
							<div>Carta che finisce con {{ payment.last4 }}</div>
							<div>Scadenza: {{ payment.exp_month }}/{{ payment.exp_year }}</div>
							<div>
								<span v-if="payment.default" class="font-bold">Predefinita</span>
								<span v-else>
									<button type="button" class="cursor-pointer text-center text-white bg-[#005961] p-[5px] my-[5px_10px] rounded-[5px] text-[0.9rem]" @click="setDefault(payment.id)">
										Imposta come predefinita
									</button>
								</span>

								<UModal :dismissible="false" v-model:open="open" title="Sei sicuro di voler eliminare la carta?" :close="false">
									<UButton
										label="Elimina carta"
										class="active:bg-[#005961] cursor-pointer text-center text-white bg-[#005961] p-[5px_10px] mt-[5px] ml-[5px] rounded-[5px] text-[0.9rem] hover:bg-[#005961]" />

									<template #body="{ close }">
										<div>
											<button type="button" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] mt-[5px] mr-[5px] rounded text-[0.9rem]" @click="deleteCard(payment.id)">
												Elimina carta
											</button>
											<UButton
												label="Annulla"
												class="active:bg-[#005961] bg-[#005961] text-white p-[10px] cursor-pointer mr-[10px] font-normal text-[0.9rem] rounded hover:bg-[#005961]"
												@click="close" />
										</div>
									</template>
								</UModal>
							</div>
						</li>
					</ul>
					<div v-else>Non hai ancora nessuna carta</div>
				</div>

				<button type="button" v-if="!showFormPayments" class="text-center text-white bg-[#005961] p-[10px] mt-[40px] rounded-[5px] cursor-pointer" @click="togglePaymentForm">
					Aggiungi una carta
				</button>

				<div class="w-[400px] mx-auto" v-if="showFormPayments">
					<label class="label-stripe-field">Numero carta</label>
					<div class="stripe-field" id="card-number"></div>

					<label class="label-stripe-field">Titolare carta</label>
					<input type="text" v-model="cardHolderName" class="stripe-field card-name placeholder:text-[#aaaaaa]" placeholder="Mario Rossi" required />

					<div class="flex items-center gap-x-[10px]">
						<div class="w-1/2">
							<label class="label-stripe-field">Data di scadenza</label>
							<div class="stripe-field" id="card-expiry"></div>
						</div>

						<div class="w-1/2">
							<label class="label-stripe-field">CVC/CVV</label>
							<div class="stripe-field" id="card-cvc"></div>
						</div>
					</div>

					<div class="text-center mt-[20px]">
						<button @click.prevent="showFormPayments = false" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] mr-[20px] rounded-[5px] inline-block">Annulla</button>
						<button @click="handleAddCard" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] rounded-[5px] inline-block">Salva carta</button>
					</div>

					<p class="text-red-500" v-if="errorMessage">{{ errorMessage }}</p>
				</div>
			</div>

			<div v-else>
				<div class="w-full max-w-sm rounded-md border border-gray-300 p-4 mb-[20px]" v-for="n in 2">
					<div class="flex animate-pulse space-x-4">
						<div class="flex-1 space-y-3 py-1">
							<div class="h-2 rounded bg-gray-300 w-[30%]"></div>
							<div class="h-2 rounded bg-gray-300 w-[50%]"></div>
							<div class="h-2 rounded bg-gray-300 w-[40%]"></div>
							<div class="h-2 rounded bg-gray-300 w-[30%]"></div>
						</div>
					</div>
				</div>
			</div>

			<p v-if="textMessage" class="text-center">
				{{ textMessage }}
			</p>
		</div>
	</section>
</template>

<style scoped>
.stripe-field.card-name {
	padding: 10px 10px;
	color: #aaaaaa;
	font-size: 15px;
}

.stripe-field {
	background-color: #f8f9fb;
	padding: 10px;
	border: 1px solid #e9ebec;
	width: 100%;
	margin-bottom: 20px;
}

.label-stripe-field {
	color: #8b8b8b;
	margin-top: 10px;
	margin-bottom: 3px;
	font-size: 0.9rem;
	display: block;
	font-family: "Inter", sans-serif;
	font-weight: bold;
}
</style>
