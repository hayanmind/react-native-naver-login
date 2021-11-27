import { NativeModules } from "react-native";

const { NaverLogin } = NativeModules;

function initialize(options) {
  NaverLogin.initialize(options);
}

function login() {
  return NaverLogin.login();
}

function logout() {
  return NaverLogin.logout();
}

export default {
  initialize,
  login,
  logout,
};
