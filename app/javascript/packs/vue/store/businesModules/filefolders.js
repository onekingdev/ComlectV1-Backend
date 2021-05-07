import axios from '../../services/axios'

import FileFolders from "../../models/FileFolders";
import AnnualReview from "../../models/AnnualReview";

export default {
  state: {
    filefolders: [],
    currentFileFolders: null,
    currentFolder: null,
  },
  mutations: {
    SET_FILEFOLDERS (state, payload) {
      state.filefolders = payload
    },
    SET_SUBFOLDER (state, payload) {
      state.filefolders.folders.push(payload)
    },
    UPDATE_FILEFOLDERS (state, payload) {
      const index = state.filefolders.findIndex(record => record.id === payload.id);
      state.filefolders.splice(index, 1, payload)
    },
    SET_NEW_FILEFOLDERS (state, payload) {
      state.filefolders.push(payload)
    },
    SET_CUREENT_FILEFOLDERS (state, payload) {
      state.currentFileFolders = payload
    },
    SET_CUREENT_FOLDER (state, payload) {
      state.currentFolder = payload
    },
    DELETE_FILEFOLDERS (state, payload) {
      const index = state.filefolders.findIndex(record => record.id === payload.id);
      state.filefolders.splice(index, 1)
    },
  },
  actions: {
    async createFolder({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.post(`/business/file_folders`, payload)
        console.log(response.data)
        if (response.data && !payload.parent_id) commit('SET_NEW_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        if (response.data && response.data.parent_id) commit('SET_SUBFOLDER', response.data)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async updateFolder({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.patch(`/business/file_folders/${payload.id}`, payload.data)
        console.log(response.data)
        if (response.data && !payload.parent_id) commit('SET_NEW_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        if (response.data && response.data.parent_id) commit('SET_SUBFOLDER', response.data)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async deleteFolder({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.delete(`/business/file_folders/${payload.id}`)
        console.log(response.data)
        if (response.data) commit('DELETE_FILEFOLDERS', response.data )
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async uploadFile({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const config = {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        };
        const response = await axios.post(`/business/file_docs`, payload, config)
        console.log(response.data)
        if (response.data) commit('SET_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async getFileFolders({ commit }) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.get(`/business/file_folders`)
        console.log(response.data)
        if (response.data) commit('SET_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async getFileFoldersById({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.get(`/business/file_folders/${payload}`)
        console.log(response.data)
        if (response.data) commit('SET_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        if (response.data) commit('SET_CUREENT_FILEFOLDERS', new FileFolders(
          response.data.files,
          response.data.folders,
        ))
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
  },
  getters: {
    filefolders: state => state.filefolders,
    currentFileFolders: state => state.currentFileFolders,
    currentFolder: state => state.currentFolder
  },
};
