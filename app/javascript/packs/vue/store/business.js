import Vue from "vue";
import Vuex from "vuex";

import policies from "./businesModules/policies";
import marketplace from "./businesModules/marketplace";
import annual from "./businesModules/annual"
import filefolders from "./businesModules/filefolders"
import exams from "./businesModules/exams"
import settings from "./businesModules/settings"
import tasks from "./businesModules/tasks"
import risks from "./businesModules/risks";
// import auth from "./commonModules/auth";
import shared from "./commonModules/shared";

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
    // auth,
    shared,
    annual: {
      namespaced: true,
      ...annual,
    },
    filefolders: {
      namespaced: true,
      ...filefolders,
    },
    marketplace: {
      namespaced: true,
      ...marketplace,
    },
    exams: {
      namespaced: true,
      ...exams,
    },
    settings: {
      namespaced: true,
      ...settings,
    },
    reminders: {
      namespaced: true,
      ...tasks,
    },
  },
});

export default store;
