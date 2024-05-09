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
    var gameId = event.target.dataset.gameGame;
    var position = event.target.dataset.gameIndex;
    var symbol = event.target.dataset.gameSymbol;

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

  renderGame(data, target) {
    target.innerHTML = `
      <div id="game-container">
        <div class="board">
          <div class="row">
            <div class="cell" ${!data.game.board[0] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="0" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[0] ? data.game.board[0] : ''}
            </div>
            <div class="cell" ${!data.game.board[1] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="1" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[1] ? data.game.board[1] : ''}
            </div>
            <div class="cell" ${!data.game.board[2] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="2" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[2] ? data.game.board[2] : ''}
            </div>
          </div>
          <div class="row">
            <div class="cell" ${!data.game.board[3] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="3" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[3] ? data.game.board[3] : ''}
            </div>
            <div class="cell" ${!data.game.board[4] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="4" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[4] ? data.game.board[4] : ''}
            </div>
            <div class="cell" ${!data.game.board[5] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="5" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[5] ? data.game.board[5] : ''}
            </div>
          </div>
          <div class="row">
            <div class="cell" ${!data.game.board[6] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="6" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[6] ? data.game.board[6] : ''}
            </div>
            <div class="cell" ${!data.game.board[7] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="7" data-game-symbol="${this.userSymbol}"` : ''}>
              ${data.game.board[7] ? data.game.board[7] : ''}
            </div>
            <div class="cell" ${!data.game.board[8] ? `data-controller="game" data-action="click->game#makeMove" data-game-game="${this.gameId}" data-game-index="8" data-game-symbol="${this.userSymbol}"` : ''}>
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
        <h1>
          ${data.game.winner_name ? '' + data.game.winner_name + ' won, congrats!' : ''}
        </h1>
      </div>
    `;
  }
}

