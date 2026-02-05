<script setup>
const { user } = useSanctumAuth();

const connectStripe = async () => {
	const { data } = await useSanctumFetch("/api/stripe/connect");
	window.location.href = data.value.url;
};

const createAccount = async () => {
	const { data } = await useSanctumFetch("/api/stripe/create-account");

	console.log(data.value);
};
</script>

<template>
	<button @click="connectStripe" v-if="!user?.stripe_account_id">Collega account Stripe</button>

	<p v-else>Account collegato correttamente a Stripe</p>

	<button @click="createAccount">Crea account Stripe</button>
</template>
