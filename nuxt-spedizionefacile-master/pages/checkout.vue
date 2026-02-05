<script setup>
import { loadStripe } from "@stripe/stripe-js";

const { user } = useSanctumAuth();

const { cart } = useCart();

const router = useRouter();

const stripePromise = loadStripe("pk_test_51RNEIjQm1dxS70cRuVsAvE6AXUo9WHTuSWZezqOLImfxG5G3hPTw1t5BwPjP44hvCL0nqxQZWdAxQwjj58yiHmZ100wjOJhkhm");

const stripe = await stripePromise;

const { data: defaultPayment } = useSanctumFetch("/api/stripe/default-payment-method");

const classPayments = "border-[2px] border-[#9BB4B1] text-center p-[5px] rounded-[4px] cursor-pointer w-full block";

definePageMeta({
	middleware: ["sanctum:auth"],
});

const coupon = ref(null);

const isCouponValid = ref(false);

const totalCoupon = ref(null);

const getTotal = computed(() => {
	if (!isCouponValid.value) {
		return cart.value.meta?.total;
	} else {
		return totalCoupon.value;
	}
});

const getNumberTotal = computed(() => {
	return Number(getTotal.value.replace("€", "").replace(",", ".").trim());
});

/* const stripe = ref(null); */
const elements = ref(null);
const paymentElement = ref(null);

let ignoreFirstEvent = true;

const selectedPaymentMethod = ref("default");

const stripePaymentMethod = ref(null);

// Richiama il backend per creare setupIntent
const {
	data: setupIntent,
	execute,
	refresh: setupIntentRefresh,
} = useSanctumFetch("/api/stripe/create-setup-intent", {
	method: "POST",
});

const checkCart = () => {
	if (!cart.value || cart.value.data.length === 0) {
		return navigateTo("/");
	}
};

await checkCart();

watch(
	[() => stripe, setupIntent],
	async ([stripeVal, newSetupIntent]) => {
		if (!stripeVal || !newSetupIntent) return;

		/* setupIntentRefresh(); */

		if (!elements.value) {
			elements.value = stripeVal.elements({ clientSecret: newSetupIntent.client_secret });
			/* paymentElement.value = elements.value.create("payment"); */
		}
	},
	{ immediate: true }
);

const onRadioChange = async (method) => {
	selectedPaymentMethod.value = method;

	if (method !== "new-card") {
		ignoreFirstEvent = true;
		stripePaymentMethod.value = null;

		if (paymentElement.value) {
			paymentElement.value.unmount();
			paymentElement.value = null;
		}
	} else {
		await nextTick();

		elements.value = stripe.elements({ clientSecret: setupIntent.value.client_secret });

		paymentElement.value = elements.value.create("payment");
		paymentElement.value.mount("#payment-element");

		paymentElement.value.on("change", (event) => {
			if (ignoreFirstEvent) {
				ignoreFirstEvent = false;
				return;
			}
			stripePaymentMethod.value = event.value.type;
		});
	}
};

const successMessage = ref(null);

const paymentMessage = ref(null);

const payWithStripe = async () => {
	paymentMessage.value = "Pagamento in corso...";

	const { data: orderData } = await useSanctumFetch("/api/stripe/create-order", {
		method: "POST",
		body: {
			subtotal: getNumberTotal.value * 100,
		},
	});

	const orderId = orderData.value.order_id;

	if (selectedPaymentMethod.value === "new-card") {
		// Pagamento con nuova carta
		const { error, paymentIntent } = await stripe.confirmPayment({
			elements,
			/* clientSecret, */ // ottenuto da createPayment backend
			redirect: "if_required",
		});

		console.log(paymentIntent);
	} else {
		// Pagamento con carta salvata
		const { data, error } = await useSanctumFetch("/api/stripe/create-payment", {
			method: "POST",
			body: {
				order_id: orderId,
				amount: getNumberTotal.value * 100,
				currency: "eur",
				customer_id: user.value.customer_id,
				payment_method_id: defaultPayment.value.card.id,
				/* coupon_code: coupon.value, */
			},
		});

		if (data.value?.status === "succeeded") {
			await refreshNuxtData("cart");

			paymentMessage.value = null;

			router.push({ query: { status: "success" } });
			successMessage.value = "Grazie per il tuo ordine!";
		} else {
			router.push({ query: { status: "failed" } });
			paymentMessage.value = error.value.data?.message;
		}
	}
};

const paymentsList = ref([
	{
		icon: "logos:mastercard",
		name: "MasterCard / Postepay",
		class: "font-size: 35px",
	},
	{
		icon: "logos:maestro",
		name: "Maestro / Postepay",
		class: "font-size: 35px",
	},
	{
		icon: "logos:visa",
		name: "Visa / Postepay",
		class: "font-size: 15px",
	},
]);

const textButton = computed(() => {
	if (selectedPaymentMethod.value === "default" && defaultPayment.value?.card) {
		return "PAGA CON CARTA SALVATA";
	}

	if (stripePaymentMethod.value === "paypal") {
		return "PAGA CON PAYPAL";
	} else if (stripePaymentMethod.value === "card") {
		return "PAGA CON NUOVA CARTA";
	} else if (stripePaymentMethod.value === "sepa_debit") {
		return "PAGA CON BONIFICO";
	}

	return;
});

const messageCoupon = ref(null);

const calculateCoupon = async (coupon) => {
	const { data } = await useSanctumFetch("/api/calculate-coupon", {
		method: "POST",
		body: {
			coupon: coupon,
			total: getNumberTotal.value,
		},
	});

	if (data.value?.success) {
		messageCoupon.value = "Coupon valido. Applicato uno sconto del " + data.value.percentage + "%";
		isCouponValid.value = true;
		totalCoupon.value = data.value.new_total;
	}

	/* await sanctum("/api/calculate-coupon", {
		method: "POST",
		body: {
			coupon: coupon,
			total: getNumberTotal.value,
		},
	}); */
};
</script>

<template>
	<section>
		<div class="my-container py-[30px]" v-if="!successMessage">
			<div class="w-[400px] mx-auto bg-white rounded-[8px] p-[20px] shadow-[0_2px_2px_#E8E8E8] mb-[20px] text-[#095866]">
				<h2 class="font-bold mb-[30px]">Riepilogo Carrello</h2>

				<div class="flex items-center justify-between">
					<h2 class="font-bold">Prodotto</h2>
					<h2 class="font-bold">Importo totale</h2>
				</div>

				<div class="flex items-center justify-between">
					<p>n. {{ cart.data?.length }}x Spedizioni</p>
					<p>
						<span :class="{ 'line-through': totalCoupon }">{{ cart.meta?.total }}</span>
						<span class="inline-block ml-[10px]" v-if="totalCoupon">{{ totalCoupon }}</span>
					</p>
				</div>
			</div>

			<div class="w-[400px] mx-auto bg-white rounded-[8px] p-[20px] mb-[20px] text-[#095866]">
				<h2>Coupon</h2>
				<label for="coupon" class="text-center block">Inserisci Coupon</label>
				<input type="text" v-model="coupon" id="coupon" class="bg-[#F8F9FB] p-[6px_10px] border border-[#E9EBEC] placeholder:text-gray-400 w-full" />
				<input
					type="button"
					@click="calculateCoupon(coupon)"
					value="Aggiungi il buono sconto"
					class="cursor-pointer text-center text-white bg-[#005961] mx-auto block p-[5px] mt-[20px] rounded-[5px] w-full" />

				<p v-if="messageCoupon" class="text-green-500">
					{{ messageCoupon }}
				</p>
			</div>

			<!-- Fatturazione -->
			<div class="w-[400px] mx-auto bg-white rounded-[8px] py-[20px] shadow-[0_2px_2px_#E8E8E8] mb-[20px] text-[#095866]">
				<div class="px-[20px]">
					<h2 class="font-bold mb-[30px]">Dettagli Fatturazione</h2>

					<p class="text-gray-500">
						Importo dei servizi fatturati:
						<span class="block font-bold">{{ getTotal }}</span>
					</p>
				</div>

				<hr class="border-gray-200 my-[15px]" />

				<div class="px-[20px]">
					<h2 class="font-bold mb-[30px]">Metodi di Pagamento</h2>

					<div v-if="setupIntent">
						<label>
							<input type="radio" name="paymentMethod" value="default" @change="onRadioChange('default')" :checked="selectedPaymentMethod === 'default'" />
							Carta salvata
						</label>

						<div v-if="selectedPaymentMethod === 'default'" class="mt-[10px]">
							<div v-if="defaultPayment?.card" class="border-[1px] border-gray-200 rounded-[5px] mb-[10px] p-[15px] text-gray-500 text-left w-full font-bold text-[0.8rem]">
								<span>Carta che finisce con {{ defaultPayment.card?.last4 }}</span>
							</div>

							<div v-else>Non hai nessuna carta predefinita</div>
						</div>

						<div class="my-[10px]">
							<label>
								<input type="radio" name="paymentMethod" value="new-card" @change="onRadioChange('new-card')" :checked="selectedPaymentMethod !== 'default'" />
								Nuova carta, paypal o SEPA
							</label>
						</div>

						<div v-if="selectedPaymentMethod === 'new-card'" id="payment-element"></div>

						<button type="button" @click="payWithStripe(order)" class="cursor-pointer text-center text-white bg-[#005961] mx-auto py-[10px] block w-full mt-[20px] rounded-[5px]" v-if="textButton">
							{{ textButton }}
						</button>
					</div>

					<div v-else>Caricamento...</div>

					<p v-if="paymentMessage" class="text-center">
						{{ paymentMessage }}
					</p>
				</div>
			</div>
		</div>

		<div class="my-container py-[30px] text-center" v-else>
			{{ successMessage }}
		</div>
	</section>
</template>

<style scoped>
.iconify {
	font-size: 25px;
}

.stripe-field.card-name {
	padding: 10px 10px;
	color: #aaaaaa;
	font-size: 15px;
}

.stripe-field {
	background-color: #fff;
	padding: 15px 10px;
	border: 1px solid #cecece;
	border-radius: 3px;
	box-shadow: inset 0 0 2px #cecece;
	width: 100%;
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
