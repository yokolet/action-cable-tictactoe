import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from '../App.vue'
import router from '../router'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
library.add(fas, far, fab)

export const firstLetter = (name: string) => name.charAt(0).toUpperCase();

const app = createApp(App);

app
  .component('font-awesome-icon', FontAwesomeIcon)
  .use(createPinia())
  .use(router)
  .mount('#app')
