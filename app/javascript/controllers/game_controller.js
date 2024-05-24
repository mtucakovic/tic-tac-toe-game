import { Controller } from "@hotwired/stimulus"
import consumer from '../channels/consumer'

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.gameId = this.element.dataset.gameId;
    this.userSymbol = this.element.dataset.gameSymbol;
    if (this.gameId) {
      this.fetchGame(this.gameId);
    }

    this.channel = consumer.subscriptions.create({ channel: 'GameChannel', id: this.gameId + '_' + this.userSymbol}, {
      received: this._cableReceived.bind(this)
    });
  }

  _cableReceived(data) {
    this.renderGame(JSON.parse(data.message), document.getElementById("game-container"));
  }

  makeMove(event) {
    var gameId = this.element.dataset.gameGame;
    var position = event.target.dataset.gameIndex;
    var symbol = this.element.dataset.gameSymbol;

    fetch(`/api/games/${gameId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ symbol: symbol, position: position}),
      dataType: "json"
    }).then((res) =>
      res.json()).then((data) =>
      this.renderGame(data, document.getElementById("game-container")))
  }

  fetchGame(gameId) {
    fetch(`/api/games/${gameId}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      }
    }).then((res) =>
      res.json()).then((data) =>
      this.renderGame(data, this.containerTarget))
  }

  newGame() {
    const newUrl = `/?name=${encodeURIComponent(this.element.dataset.gameName)}`;
    window.location.href = newUrl;
  }

  renderGame(data, target) {
    target.innerHTML = `
      <div id="game-container" data-controller="game" data-game-game="${this.gameId}" data-game-symbol="${this.userSymbol}">
        <div class="board">
          <div class="row">
            <div class="cell" ${!data.game.board[0] ? `data-action="click->game#makeMove" data-game-index="0"` : ''}>
              ${data.game.board[0] ? data.game.board[0] : ''}
            </div>
            <div class="cell" ${!data.game.board[1] ? `data-action="click->game#makeMove" data-game-index="1"` : ''}>
              ${data.game.board[1] ? data.game.board[1] : ''}
            </div>
            <div class="cell" ${!data.game.board[2] ? `data-action="click->game#makeMove" data-game-index="2"` : ''}>
              ${data.game.board[2] ? data.game.board[2] : ''}
            </div>
          </div>
          <div class="row">
            <div class="cell" ${!data.game.board[3] ? `data-action="click->game#makeMove" data-game-index="3"` : ''}>
              ${data.game.board[3] ? data.game.board[3] : ''}
            </div>
            <div class="cell" ${!data.game.board[4] ? `data-action="click->game#makeMove" data-game-index="4"` : ''}>
              ${data.game.board[4] ? data.game.board[4] : ''}
            </div>
            <div class="cell" ${!data.game.board[5] ? `data-action="click->game#makeMove" data-game-index="5"` : ''}>
              ${data.game.board[5] ? data.game.board[5] : ''}
            </div>
          </div>
          <div class="row">
            <div class="cell" ${!data.game.board[6] ? `data-action="click->game#makeMove" data-game-index="6"` : ''}>
              ${data.game.board[6] ? data.game.board[6] : ''}
            </div>
            <div class="cell" ${!data.game.board[7] ? `data-action="click->game#makeMove" data-game-index="7"` : ''}>
              ${data.game.board[7] ? data.game.board[7] : ''}
            </div>
            <div class="cell" ${!data.game.board[8] ? `data-action="click->game#makeMove" data-game-index="8"` : ''}>
              ${data.game.board[8] ? data.game.board[8] : ''}
            </div>
          </div>
        </div>

        <h4>
          Player X: ${data.game.player_x_name} | Player O: ${data.game.player_o_name ? data.game.player_o_name : ''}
        </h4>
        <h3 class='${data.game.status}'>
          ${data.game.status === 'in_progress' ? 'current symbol: ' + data.game.current_symbol.toUpperCase() : data.game.status.replace(/_/g, ' ').toUpperCase()}
        </h3>
        <h3 class='turn-info'>
          ${(data.game.status === 'in_progress') ? (data.game.current_symbol === this.userSymbol ? 'Your turn!' : 'Other person turn!') : ''}
        </h3>
        <h1>
          ${data.game.winner_name ? ( (data.game.current_symbol !== this.userSymbol) ? data.game.winner_name + ' won, congrats!' : data.game.winner_name + ' won, try again?') : ''}
        </h1>
      </div>
    `;
  }
}
