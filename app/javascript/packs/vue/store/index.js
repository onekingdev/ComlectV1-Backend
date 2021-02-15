import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const URL_PROJECT_SHOW = '/business/projects/:id'
const URL_PROJECT_APPLICATIONS = `${URL_PROJECT_SHOW}/applications`
const URL_API_PROJECT_APPLICATIONS = `/api${URL_PROJECT_APPLICATIONS}`
const URLS = {
  URL_PROJECT_SHOW,
  URL_PROJECT_APPLICATIONS,
  URL_API_PROJECT_APPLICATIONS
}

const store = new Vuex.Store({
  getters: {
    url: () => (url, id) => URLS[url].replace(':id', id)
  }
})

export default store