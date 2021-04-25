import Vue from "vue";
import Vuex from "vuex";

import policies from "./businesModules/policies";
import annual from "./businesModules/annual"
import risks from "./businesModules/risks";
import shared from "./shared";
import auth from "./businesModules/auth";

Vue.use(Vuex);

const URL_PROJECT_SHOW = "/business/projects/:id";
const URL_PROJECT_POST = `/business/project_posts/:id`;
const URL_API_PROJECT = `/api${URL_PROJECT_SHOW}`;
const URL_API_PROJECT_APPLICATIONS = `/api${URL_PROJECT_SHOW}/applications`;
const URL_API_PROJECT_HIRES = `/api${URL_PROJECT_SHOW}/hires`;
const URL_POST_LOCAL_PROJECT = "/business/projects/new?local_project_id=:id";
const URL_PROJECT_TIMESHEETS = `${URL_PROJECT_SHOW}/timesheets`;
const URL_API_PROJECT_TIMESHEETS = `/api${URL_PROJECT_TIMESHEETS}`;

const URL_POLICIES_SHOW = "/business/compliance_policies/:id";
const URL_RISKS_SHOW = "/business/risks/:id";

const URLS = {
  URL_PROJECT_SHOW,
  URL_PROJECT_POST,
  URL_API_PROJECT,
  URL_API_PROJECT_APPLICATIONS,
  URL_API_PROJECT_HIRES,
  URL_POST_LOCAL_PROJECT,
  URL_PROJECT_TIMESHEETS,
  URL_API_PROJECT_TIMESHEETS,

  URL_POLICIES_SHOW,
  URL_RISKS_SHOW,
};

const store = new Vuex.Store({
  getters: {
    url: () => (url, id) => URLS[url].replace(":id", id),
  },

  modules: {
    policies,
    risks,
    // policies: {
    //   namespaced: true,
    //   ...policies,
    //   // archives: {
    //   //
    //   // }
    // },
    shared,
    annual: {
      namespaced: true,
      ...annual,
    },
    auth,
  },
});

export default store;
