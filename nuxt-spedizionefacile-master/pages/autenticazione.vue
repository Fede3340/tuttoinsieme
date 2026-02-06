<script setup>
import { FetchError } from "ofetch";

const { login } = useSanctumAuth();

const items = ref([
	{
		label: "Accedi",
		icon: "",
		slot: "accedi",
		disabled: false,
	},
	{
		label: "Registrati",
		icon: "",
		slot: "registrati",
		disabled: false,
	},
]);

const credentials = ref({
	email: "vale@example.com",
	password: "C1a!0.Gg",
	remember: false,
});

const messageError = ref(null);

const limitMessageError = ref(null);

const messageSuccess = ref(null);

const messageLoading = ref(null);

const isLoading = ref(false);

const isGoogle = ref(false);

const handleLogin = async () => {
	messageError.value = null;

	if (!isGoogle.value) {
		messageLoading.value = "Login in corso...";
	}

	isLoading.value = true;

	try {
		await useSanctumFetch("/sanctum/csrf-cookie");

		const response = await login(credentials.value, {
			/* headers: {
				"ngrok-skip-browser-warning": "skip-browser-warning",
			}, */
		});

		items.value.forEach((item) => {
			item.disabled = true;
		});

		if (response) {
			if (!messageError.value) {
				credentials.value.email = null;
				credentials.value.password = null;
				credentials.value.remember = false;
			}

			isLoading.value = false;

			/* await getCart(); */
		}
	} catch (error) {
		if (error instanceof FetchError && error.response?.status === 422) {
			messageError.value = error.response?._data.errors;
		}

		if (error.response?.status === 401 || error.response?.status === 429) {
			messageError.value = error.response._data;
		}

		/* if (error.response?.status === 429) {
			limitMessageError.value = error.response._data;
		} */
	} finally {
		messageLoading.value = null;
	}
};

definePageMeta({
	middleware: ["sanctum:guest"],
});

const apiBase = useRuntimeConfig().public.apiBase;

const registerForm = ref({
	name: "Valee",
	surname: "Chicco",
	email: "vale@example.com",
	email_confirmation: "vale@example.com",
	prefix: "+39",
	telephone_number: "3333333333",
	password: "C1a!0.Gg",
	password_confirmation: "C1a!0.Gg",
	role: "Cliente",
});

const registerUser = async () => {
	messageError.value = null;

	messageLoading.value = "Registrazione in corso...";

	items.value.forEach((item) => {
		item.disabled = true;
	});

	isLoading.value = true;

	try {
		await useSanctumFetch("/sanctum/csrf-cookie");

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
		isLoading.value = false;
		items.value.forEach((item) => {
			item.disabled = false;
		});
	}
};

const showForm = ref(false);

const loginGoogle = () => {
	isGoogle.value = true;
	window.location.href = `${apiBase}/api/auth/google/redirect`;
};

function onTabClick(newValue) {
	/* console.log("Hai cliccato il tab:", newValue); */
	// qui puoi fare quello che ti serve

	if (messageError.value) {
		messageError.value = null;
	}
}
</script>

<template>
	<section>
		<div class="my-container">
			<div class="mx-auto w-[380px] py-[30px]">
				<p v-if="messageSuccess" class="bg-white p-[20px] rounded-[8px] text-[#4D4D4D] text-center">{{ messageSuccess }}</p>

				<UTabs :items="items" v-if="!messageSuccess" @update:modelValue="onTabClick">
					<template #accedi>
						<UForm :state="credentials" @submit.prevent="handleLogin" class="bg-white p-[20px] rounded-[8px] shadow-[0_2px_2px_#E8E8E8] text-[#095866] mt-[30px]">
							<label for="login_email">Email</label>
							<input type="email" id="login_email" v-model="credentials.email" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[10px]" required />
							<label for="login_password">Password</label>
							<input type="password" id="login_password" v-model="credentials.password" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full" required />
							<p v-if="messageError?.email" class="text-red-500">
								{{ messageError.email[0] }}
							</p>
							<input type="submit" value="Accedi" class="cursor-pointer text-center text-white bg-[#005961] mx-auto py-[10px] block w-full mt-[20px] rounded-[5px]" />

							<button @click="loginGoogle" class="flex items-center gap-[10px] border-[1px] border-black rounded-[30px] p-[10px_20px] cursor-pointer mx-auto my-[20px]">
								<Icon name="flat-color-icons:google" class="google-icon" />
								<span>Accedi con Google</span>
							</button>

							<p>
								Hai dimenticato la password?
								<NuxtLink to="/recupera-password"><span class="font-bold">Recupera Password</span></NuxtLink>
							</p>
							<p v-if="messageLoading" class="text-center mt-[20px]">
								{{ messageLoading }}
							</p>

							<p v-if="messageError?.message" class="text-red-500 w-full text-center">
								{{ messageError?.message }}
							</p>
						</UForm>
					</template>

					<template #registrati>
						<h2 class="font-bold text-center mb-[10px] text-[#095866] mt-[30px]">REGISTRA UN ACCOUNT</h2>

						<UForm :state="registerForm" @submit.prevent="registerUser">
							<select id="role" v-model="registerForm.role" class="border border-[rgba(0,0,0,0.1)] block mx-auto text-[#095866] p-[5px] w-[90%]">
								<option value="" disabled hidden>Tipologia cliente</option>
								<option value="Cliente">Cliente</option>
								<option value="Partner Pro">Partner Pro</option>
							</select>

							<div class="bg-white p-[20px] rounded-[8px] shadow-[0_2px_2px_#E8E8E8] text-[#095866] mt-[20px]">
								<label for="name">Nome *</label>
								<input type="text" id="name" v-model="registerForm.name" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[5px]" required />

								<label for="surname">Cognome *</label>
								<input type="text" id="surname" v-model="registerForm.surname" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]" required />

								<label for="prefix" class="sr-only">Prefisso</label>
								<select v-model="registerForm.prefix" id="prefix" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]">
									<option value="+39">(+39) Italia</option>
									<option value="+49">(+49) Germania</option>
								</select>

								<label for="telephone_number" class="sr-only">Telefono cellulare *</label>
								<input
									type="tel"
									id="telephone_number"
									placeholder="Telefono cellulare *"
									v-model="registerForm.telephone_number"
									class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
									required />

								<label for="registration_email" class="sr-only">Email *</label>
								<input
									type="email"
									id="registration_email"
									placeholder="Email *"
									v-model="registerForm.email"
									class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
									required />

								<label for="registration_email_confirmation" class="sr-only">Conferma Email *</label>
								<input
									type="email"
									id="registration_email_confirmation"
									placeholder="Conferma Email *"
									v-model="registerForm.email_confirmation"
									class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
									required />

								<p v-if="messageError?.email" class="text-red-500">
									{{ messageError.email[0] }}
								</p>

								<label for="registration_password" class="sr-only">Password *</label>
								<input
									type="password"
									id="registration_password"
									placeholder="Password *"
									v-model="registerForm.password"
									class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
									required />

								<label for="registration_password_confirmation" class="sr-only">Conferma Password *</label>
								<input
									type="password"
									id="registration_password_confirmation"
									placeholder="Conferma Password *"
									v-model="registerForm.password_confirmation"
									class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
									required />

								<p v-if="messageError?.password" class="text-red-500">
									<span v-for="(error, index) in messageError.password" :key="index" class="block">
										{{ error }}
									</span>
								</p>
							</div>

							<input type="submit" value="Registrati" class="cursor-pointer text-center text-white bg-[#005961] mx-auto block p-[10px] mt-[20px] rounded-[5px]" />

							<p v-if="messageLoading" class="text-center mt-[20px]">
								{{ messageLoading }}
							</p>
						</UForm>
					</template>
				</UTabs>

				<!-- <div class="flex items-center justify-center gap-x-[30px] mb-[30px]" v-if="!messageSuccess">
					<button
						type="button"
						@click="
							showForm = false;
							messageError = null;
						"
						class="cursor-pointer"
						:disabled="isLoading">
						Accedi
					</button>
					<button
						type="button"
						@click="
							showForm = true;
							messageError = null;
						"
						class="cursor-pointer"
						:disabled="isLoading">
						Registrati
					</button>
				</div> -->

				<!-- <form @submit.prevent="handleLogin" class="bg-white p-[20px] rounded-[8px] shadow-[0_2px_2px_#E8E8E8] text-[#095866]" v-if="!showForm">
					<label for="login_email">Email</label>
					<input type="email" id="login_email" v-model="credentials.email" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[10px]" required />
					<label for="login_password">Password</label>
					<input type="password" id="login_password" v-model="credentials.password" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full" required />
					<p v-if="messageError?.email" class="text-red-500">
						{{ messageError.email[0] }}
					</p>
					<input type="submit" value="Accedi" class="cursor-pointer text-center text-white bg-[#005961] mx-auto py-[10px] block w-full mt-[20px] rounded-[5px]" />

					<button @click="loginGoogle" class="flex items-center gap-[10px] border-[1px] border-black rounded-[30px] p-[10px_20px] cursor-pointer mx-auto my-[20px]">
						<Icon name="flat-color-icons:google" class="google-icon" />
						<span>Accedi con Google</span>
					</button>

					<p>
						Hai dimenticato la password?
						<NuxtLink to="/recupera-password"><span class="font-bold">Recupera Password</span></NuxtLink>
					</p>
					<p v-if="messageLoading" class="text-center mt-[20px]">
						{{ messageLoading }}
					</p>

					<p v-if="messageError?.message" class="text-red-500 w-full text-center">
						{{ messageError?.message }}
					</p>
				</form> -->

				<!-- <div v-else>
					<h2 class="font-bold text-center mb-[10px] text-[#095866]">REGISTRA UN ACCOUNT</h2>

					<p v-if="messageSuccess" class="bg-white p-[20px] rounded-[8px] text-[#4D4D4D] text-center">{{ messageSuccess }}</p>

					<form @submit.prevent="registerUser" v-else>
						<select id="role" v-model="registerForm.role" class="border border-[rgba(0,0,0,0.1)] block mx-auto text-[#095866] p-[5px] w-[90%]">
							<option value="" disabled hidden>Tipologia cliente</option>
							<option value="Cliente">Cliente</option>
							<option value="Partner Pr">Partner Pro</option>
						</select>

						<div class="bg-white p-[20px] rounded-[8px] shadow-[0_2px_2px_#E8E8E8] text-[#095866] mt-[20px]">
							<label for="name">Nome *</label>
							<input type="text" id="name" v-model="registerForm.name" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[5px]" required />

							<label for="surname">Cognome *</label>
							<input type="text" id="surname" v-model="registerForm.surname" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]" required />

							<label for="prefix" class="sr-only">Prefisso</label>
							<select v-model="registerForm.prefix" id="prefix" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]">
								<option value="+39">(+39) Italia</option>
								<option value="+49">(+49) Germania</option>
							</select>

							<label for="telephone_number" class="sr-only">Telefono cellulare *</label>
							<input
								type="tel"
								id="telephone_number"
								placeholder="Telefono cellulare *"
								v-model="registerForm.telephone_number"
								class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
								required />

							<label for="registration_email" class="sr-only">Email *</label>
							<input
								type="email"
								id="registration_email"
								placeholder="Email *"
								v-model="registerForm.email"
								class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
								required />

							<label for="registration_email_confirmation" class="sr-only">Conferma Email *</label>
							<input
								type="email"
								id="registration_email_confirmation"
								placeholder="Conferma Email *"
								v-model="registerForm.email_confirmation"
								class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
								required />

							<p v-if="messageError?.email" class="text-red-500">
								{{ messageError.email[0] }}
							</p>

							<label for="registration_password" class="sr-only">Password *</label>
							<input
								type="password"
								id="registration_password"
								placeholder="Password *"
								v-model="registerForm.password"
								class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
								required />

							<label for="registration_password_confirmation" class="sr-only">Conferma Password *</label>
							<input
								type="password"
								id="registration_password_confirmation"
								placeholder="Conferma Password *"
								v-model="registerForm.password_confirmation"
								class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
								required />

							<p v-if="messageError?.password" class="text-red-500">
								<span v-for="(error, index) in messageError.password" :key="index" class="block">
									{{ error }}
								</span>
							</p>
						</div>

						<input type="submit" value="Registrati" class="cursor-pointer text-center text-white bg-[#005961] mx-auto block p-[10px] mt-[20px] rounded-[5px]" />

						<p v-if="messageLoading" class="text-center mt-[20px]">
							{{ messageLoading }}
						</p>
					</form>
				</div> -->
			</div>
		</div>
	</section>
</template>

<style scoped>
.google-icon {
	font-size: 30px;
}
</style>
