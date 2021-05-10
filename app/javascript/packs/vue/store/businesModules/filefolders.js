import axios from '../../services/axios'

import FileFolders from "../../models/FileFolders";
import AnnualReview from "../../models/AnnualReview";

export default {
  state: {
    filefolders: [],
    currentFileFolders: null,
    currentFolder: null,
    currentFolderName: null,
  },
  mutations: {
    SET_FILEFOLDERS (state, payload) {
      state.filefolders = payload
    },
    SET_FOLDER (state, payload) {
      state.filefolders.folders.push(payload)
    },
    UPDATE_FOLDER (state, payload) {
      const index = state.filefolders.folders.findIndex(record => record.id === payload.id);
      state.filefolders.folders.splice(index, 1, payload)
    },
    SET_NEW_FILE (state, payload) {
      state.filefolders.files.push(payload)
    },
    UPDATE_FILE (state, payload) {
      const index = state.filefolders.files.findIndex(record => record.id === payload.id);
      state.filefolders.files.splice(index, 1, payload)
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
      const type = payload.itemType === 'folder' ? 'folders' : 'files';
      const index = state.filefolders[type].findIndex(record => record.id === payload.id);
      state.filefolders[type].splice(index, 1)
    },
    SET_CUREENT_FOLDER_NAME (state, payload) {
      state.currentFolderName = payload
    },
  },
  actions: {
    async createFolder({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const response = await axios.post(`/business/file_folders`, payload)
        // console.log(response.data)
        if (response.data) commit('SET_FOLDER', response.data)
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
        // console.log(response.data)
        // if (response.data && !payload.parent_id) commit('SET_NEW_FILEFOLDERS', new FileFolders(
        //   response.data.files,
        //   response.data.folders,
        // ))
        if (response.data) commit('UPDATE_FOLDER', response.data)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async deleteFileFolder({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        console.log('payload', payload)
        const { id, itemType  } = payload
        const endpoint = itemType === 'folder' ? 'file_folders' : 'file_docs'
        const response = await axios.delete(`/business/${endpoint}/${id}`)
        // console.log(response.data)
        if (response.data) commit('DELETE_FILEFOLDERS', payload )
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
          timeout: 5000,
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        };
        const response = await axios.post(`/business/file_docs`, payload, config)
        if (response.data) commit('SET_NEW_FILE', response.data)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        commit("setLoading", false, { root: true });
        throw error;
      } finally {
        commit("setLoading", false, { root: true })
      }
    },
    async updateFile({ commit }, payload) {
      commit("clearError", null, { root: true });
      commit("setLoading", true, { root: true });
      try {
        const config = {
          timeout: 5000,
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        };
        const response = await axios.patch(`/business/file_docs/${payload.id}`, payload.data, config)
        if (response.data) commit('UPDATE_FILE', response.data)
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
        // console.log(response.data)
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
        // console.log(response.data)
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
    async getFileFoldersListTree({ commit }, payload) {
      commit("clearError", null, { root: true });
      // commit("setLoading", true, { root: true });
      try {
        const response = await axios.get(`/business/file_folders/${payload}/list_tree`)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        // commit("setLoading", false, { root: true });
        throw error;
      } finally {
        // commit("setLoading", false, { root: true })
      }
    },
    async startZipping({ commit, getters }, payload) {
      commit("clearError", null, { root: true });
      // commit("setLoading", true, { root: true });
      try {
        // console.log(commit, getters)
        const id = payload.id ? payload.id : getters.currentFolder
        const response = await axios.get(`/business/file_folders/${id}/download_folder`)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        // commit("setLoading", false, { root: true });
        throw error;
      } finally {
        // commit("setLoading", false, { root: true })
      }
    },
    async checkZipping({ commit, getters }, payload) {
      commit("clearError", null, { root: true });
      // commit("setLoading", true, { root: true });
      try {
        // console.log(commit, getters)
        const id = payload.id ? payload.id : getters.currentFolder
        const response = await axios.get(`/business/file_folders/${id}/check_zip`)
        return response.data
      } catch (error) {
        commit("setError", error.message, { root: true });
        // commit("setLoading", false, { root: true });
        throw error;
      } finally {
        // commit("setLoading", false, { root: true })
      }
    },
  },
  getters: {
    filefolders: state => state.filefolders,
    currentFileFolders: state => state.currentFileFolders,
    currentFolder: state => state.currentFolder,
    currentFolderName: state => state.currentFolderName
  },
};
