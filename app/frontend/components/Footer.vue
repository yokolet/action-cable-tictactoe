<script setup lang="ts">
import { ref } from 'vue';

interface ISocial {
  icon: string[],
  url: string,
}

const socials = ref<ISocial[]>([
  {
    icon: ['fab', 'gitlab'],
    url: 'https://gitlab.com/yokolet',
  },
  {
    icon: ['fab', 'github'],
    url: 'https://github.com/yokolet',
  },
  {
    icon: ['fab', 'linkedin'],
    url: 'https://www.linkedin.com/in/yokolet/',
  },
  {
    icon: ['fab', 'x-twitter'],
    url: 'https://x.com/yokolet',
  }
]);
</script>

<template>
  <div
      class="container flex flex-col md:flex-row min-h-56 md:min-w-full md:min-h-dvh
      text-3xl bg-slate-900 text-white p-4"
  >
    <div class="flex items-start justify-center md:w-1/2">
      <a class="text-lg md:text-2xl hover:text-lightBlue hover:scale-110"
          href="https://gitlab.com/yokolet/action-cable-tictactoe"
      >
        About
        <font-awesome-icon :icon="['fas', 'circle-chevron-right']" />
      </a>
    </div>
    <div class="md:w-1/2 pt-4">
      <div class="flex flex-col items-center md:items-start md:justify-end space-y-4">
        <div class="text-lg md:text-xl md:justify-end  space-x-6">
          <a
              class="hover:text-lightBlue hover:scale-110"
              v-for="social in socials"
              :href="social.url"
          >
            <span class="md:text-2xl"><font-awesome-icon :icon="social.icon" /></span>
          </a>
        </div>
        <div class="text-sm md:text-lg text-lightBlue">
          &copy; 2024 Yoko Harada. All rights reserved
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>
