class Policy {
  constructor(id = null, ownerId = null, title, description, sections = null) {
    this.id = id;
    this.ownerId = ownerId;
    this.title = title;
    this.description = description;
    this.sections = sections;
  }
}

export default {
  state: {
    policies: [],
    sections: [],
  },
  mutations: {
    createPolicy(state, payload) {
      state.policies.push(payload);
    },
    updatePolicy(state, payload) {
      state.policies[0].sections.push(payload);
    },
    createSections(state, payload) {
      state.sections.push(payload);
    },
  },
  actions: {
    async createPolicy({ commit, getters }, payload) {
      commit("clearError");
      commit("setLoading", true);

      try {
        const newPolicy = new Policy(
            payload.id,
            payload.ownerId,
            payload.title,
            payload.description,
            payload.sections,
            //   getters.user.id,
        );

        setTimeout(() => {
          commit("setLoading", false);
          commit("createPolicy", {
            ...newPolicy,
            //   id: policy.key,
          });
        }, 3000);
      } catch (error) {
        commit("setError", error.message);
        commit("setLoading", false);
        throw error;
      }
    },
    async createSection({ commit, getters }, payload) {
      console.log(payload)
      commit("clearError");
      commit("setLoading", true);

      try {
        const newSection = {
          id: payload.id,
          title: payload.title,
          description: payload.description,
          children: payload.children
        };

        setTimeout(() => {
          commit("setLoading", false);
          commit('updatePolicy', { ...newSection })
        }, 3000);
      } catch (error) {
        commit("setError", error.message);
        commit("setLoading", false);
        throw error;
      }
    },
    // async getPolicyById ({commit, getters}, payload) {
    //     const endpointUrl = '/api/business/compliance_policies/'
    //
    //     const data = await fetch(`${endpointUrl}1`, { headers: {'Accept': 'application/json'}})
    //         .then(response => {
    //             console.log(response)
    //             response.json()
    //         })
    //         .then(result => console.log(result))
    //         .catch(error => console.log(error))
    //     return data;
    // },
    async getPolicies ({commit, getters}, payload) {
      console.log(payload)
        const endpointUrl = '/api/business/compliance_policies/'

        const data = await fetch(`${endpointUrl}`, { headers: {'Accept': 'application/json'}})
            .then(response => {
                console.log(response)
                response.json()
            })
            .then(result => console.log(result))
            .catch(error => console.log(error))
        return data;
    },
  },
  getters: {
    policies(state) {
      return state.policies;
    },
  },
};
