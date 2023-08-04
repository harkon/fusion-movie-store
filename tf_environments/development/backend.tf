terraform {
  backend "local" {
    path = "../../tf_state/development"
  }
}