<script setup>
definePageMeta({
	middleware: ["sanctum:auth", "admin"],
});

const { refresh } = UseAdminImage();

const adminImage = ref(null);

const imagePreview = ref(null);

const refInput = ref(null);

const sanctum = useSanctumClient();

const uploadFile = async () => {
	const formData = new FormData();
	formData.append("admin_image", adminImage.value);

	await sanctum("/api/upload-file", {
		method: "POST",
		body: formData,
	});

	await refresh();
};

const changeFile = (e) => {
	adminImage.value = e.target.files[0];
	const file = e.target.files[0];

	if (file) {
		const reader = new FileReader();
		reader.onload = (e) => {
			imagePreview.value = e.target?.result;
		};
		reader.readAsDataURL(file);
	}

	if (!file) {
		imagePreview.value = "";
	}
};
</script>

<template>
	<section>
		<div class="my-container py-[80px]">
			<p class="text-center">Solo per admin</p>

			<!-- <div class="my-[80px]">
				<NuxtLink to="/dashboard/admin/ordini">Vai agli ordini</NuxtLink>
			</div> -->

			<form @submit.prevent="uploadFile" enctype="multipart/form-data">
				<label for="admin_image" class="block sr-only">Carica immagine</label>
				<input type="file" name="admin_image" id="upload-image" accept="image/*" @change="changeFile" class="mr-[15px]" ref="refInput" />

				<input type="submit" value="Invia" class="block" />
			</form>

			<div v-if="imagePreview" class="mb-[20px]">
				<h3 class="text-[18px] font-semibold cursor-text pb-[5px]">Preview Immagine</h3>

				<img :src="imagePreview" alt="" class="max-w-[400px] max-h-[400px]" />
			</div>
		</div>
	</section>
</template>
