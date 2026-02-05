<script setup>
definePageMeta({
	middleware: ["sanctum:auth"],
});

const { refreshIdentity, user, logout } = useSanctumAuth();

const messageError = ref(null);

const messageSuccess = ref(null);

const messageLoading = ref(null);

const showEditForm = ref(false);

const userInfo = ref({
	name: user.value.name,
	email: user.value.email,
	password: "",
	telephone_number: user.value.telephone_number,
});

const sanctum = useSanctumClient();

const updateInfo = async () => {
	messageError.value = null;

	messageLoading.value = "Modifiche in corso...";

	try {
		await sanctum(`/api/users/${user.value.id}`, {
			method: "PATCH",
			body: userInfo.value,
			"ngrok-skip-browser-warning": "skip-browser-warning",
		});

		/* console.log(response.value?.message); */

		await refreshIdentity();

		/* messageError.value = error.value?.data?.errors; */

		/* messageSuccess.value = response.value?.message; */
	} catch (error) {
		if (error) {
			console.log(error);
		}

		if (error?.statusCode === 401) {
			navigateTo("/autenticazione");
		}
	} finally {
		messageLoading.value = null;
		showEditForm.value = false;
		/* setTimeout(() => {
			messageSuccess.value = null;
		}, 2000); */
	}
};

const getTitle = computed(() => {
	if (showEditForm.value) {
		return "Modifica dati";
	} else {
		return "Informazioni profilo";
	}
});

const getTelephoneNumber = (telephone_number) => {
	if (telephone_number === "0") {
		return "Non ancora aggiunto";
	} else {
		return telephone_number;
	}
};

const handleLogout = async () => {
	try {
		await useSanctumFetch("/sanctum/csrf-cookie");

		await logout();
	} catch (error) {
		if (error?.statusCode === 401) {
			navigateTo("/");
		}
	}
};
</script>

<template>
	<section class="min-h-[400px] py-[80px]">
		<div class="my-container">
			<div class="mb-[20px]">
				<NuxtLink to="/account" class="hover:underline">Il tuo account</NuxtLink>
				›
				<span :class="{ 'font-bold': !showEditForm }">Informazioni profilo</span>
				<span v-if="showEditForm">
					›
					<span class="font-bold">Modifica dati</span>
				</span>
			</div>

			<h1 class="font-bold text-[2rem]">{{ getTitle }}</h1>

			<button @click.prevent="handleLogout" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] mt-[40px] rounded-[5px]">Effettua il Logout</button>

			<ul class="font-[1.5rem] flex flex-col gap-[10px] mt-[10px]" v-if="!showEditForm">
				<li>
					<span class="font-bold">Tipo di account:</span>
					{{ user?.role }}
				</li>
				<li>
					<span class="font-bold">Nome:</span>
					{{ user?.name }}
				</li>
				<li>
					<span class="font-bold">Email:</span>
					{{ user?.email }}
				</li>
				<li>
					<span class="font-bold">Password:</span>
					************
				</li>
				<li>
					<span class="font-bold">Numero di telefono:</span>
					{{ getTelephoneNumber(user?.telephone_number) }}
				</li>
			</ul>

			<button v-if="!showEditForm" @click="showEditForm = true" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] mt-[20px] rounded-[5px]">Modifica dati</button>

			<div v-if="showEditForm" class="mx-auto w-[380px]">
				<form @submit.prevent="updateInfo">
					<label for="name">Nome</label>
					<input type="text" v-model="userInfo.name" class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]" id="name" :required="userInfo.name === ''" />

					<label for="email">Email</label>
					<input
						type="email"
						v-model="userInfo.email"
						id="email"
						class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
						:required="userInfo.email === ''" />

					<label for="telephone_number">Numero di telefono</label>
					<input
						type="text"
						v-model="userInfo.telephone_number"
						id="telephone_number"
						class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
						placeholder="Inserisci il numero di telefono" />

					<label for="password">Password</label>
					<input
						type="password"
						v-model="userInfo.password"
						id="password"
						class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
						placeholder="Modifica la password" />

					<label for="password_confirmation">Conferma Password</label>
					<input
						type="password"
						v-model="userInfo.password_confirmation"
						class="bg-[#F8F9FB] p-[10px] border-b border-[#E9EBEC] placeholder:text-gray-400 w-full mb-[20px]"
						id="password_confirmation"
						placeholder="Conferma la password" />

					<div class="text-center mt-[20px]">
						<button @click.prevent="showEditForm = false" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] mr-[20px] rounded-[5px] inline-block">Annulla</button>
						<button @click="handleAddCard" class="cursor-pointer text-center text-white bg-[#005961] p-[10px] rounded-[5px] inline-block">Aggiorna dati</button>
					</div>

					<p v-if="messageLoading" class="text-center">
						{{ messageLoading }}
					</p>
				</form>
				<!-- <p v-if="messageSuccess" class="text-green-500">
					{{ messageSuccess }}
				</p> -->
			</div>
		</div>
	</section>
</template>
