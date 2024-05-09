import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name"]

  joinGame() {
    var name = this.nameTarget.value;

    if (!name) {
      alert("Please enter your name.");
      return;
    }

    fetch("/api/games", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ name: name }),
    }).then((res) =>
        res.json()).then((data) =>
        window.location.href = `/games/${data.game.id}?symbol=${data.game.player_o_name ? 'o' : 'x'}&name=${name}`)
  }
}