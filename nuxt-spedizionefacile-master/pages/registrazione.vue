<script setup>
const registerForm = ref({
	name: "Valee",
	email: "vale@example.com",
	password: "C1a!0.Gg",
	password_confirmation: "C1a!0.Gg",
	role: "Cliente",
});

const messageError = ref(null);

const messageSuccess = ref(null);

const messageLoading = ref(null);

const registerUser = async () => {
	messageError.value = null;

	messageLoading.value = "Registrazione in corso...";

	try {
		const { data: response, error } = await useSanctumFetch("/api/custom-register", {
			method: "POST",
			body: registerForm.value,
			headers: {
				"ngrok-skip-browser-warning": "skip-browser-warning",
			},
		});

		messageError.value = error.value?.data?.errors;

		messageSuccess.value = response.value?.message;
	} catch (error) {
		if (error) {
			console.log(error);
		}
	} finally {
		messageLoading.value = null;
	}
};

definePageMeta({
	middleware: ["sanctum:guest"],
});
</script>

<template>
	<section class="h-[400px]">
		<div class="my-container flex justify-center items-center h-full">
			<p v-if="messageSuccess" class="text-green-500">
				{{ messageSuccess }}
			</p>

			<form @submit.prevent="registerUser" v-else>
				<div class="flex items-center justify-between mb-[10px]">
					<div class="flex items-center gap-x-[5px]">
						<input type="radio" id="client" value="Cliente" v-model="registerForm.role" />
						<label for="client">Cliente</label>
					</div>

					<div class="flex items-center gap-x-[5px]">
						<input type="radio" id="partner_pro" value="Partner Pro" v-model="registerForm.role" />
						<label for="partner_pro">Partner Pro</label>
					</div>
				</div>

				<label for="name">Nome:</label>
				<input type="text" id="name" v-model="registerForm.name" required />

				<label for="email">Email:</label>
				<input type="email" id="email" v-model="registerForm.email" required />
				<p v-if="messageError?.email" class="text-red-500">
					{{ messageError.email[0] }}
				</p>

				<label for="password">Password:</label>
				<input type="password" id="password" v-model="registerForm.password" required />

				<label for="password_confirmation">Password confirmation:</label>
				<input type="password" id="password_confirmation" v-model="registerForm.password_confirmation" required />
				<p v-if="messageError?.password" class="text-red-500">
					<span v-for="(error, index) in messageError.password" :key="index" class="block">
						{{ error }}
					</span>
				</p>

				<button type="submit" class="bg-[#E44203] text-white p-[10px] cursor-pointer mx-auto block mt-[20px]">Registrati</button>

				<p v-if="messageLoading">
					{{ messageLoading }}
				</p>
			</form>
		</div>
	</section>
</template>

<style scoped>
select,
input {
	display: block;
	margin: 10px 0;
	background-color: rgba(0, 0, 0, 0.1);
	color: rgba(0, 0, 0, 0.4);
}
</style>
