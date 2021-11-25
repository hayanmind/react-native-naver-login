import {NativeModules} from "react-native";

const {NaverLogin} = NativeModules;

async function initialize(options) {
  NaverLogin.initialize(options);
}

async function login() {
  return await NaverLogin.login();
}

async function logout() {
  return await NaverLogin.logout();
}

export default {
  initialize,
  login,
  logout,
};
