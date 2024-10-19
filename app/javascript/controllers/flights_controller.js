import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flights"
export default class extends Controller {

  static values = {
    flightsData: Object,
  }
  static targets = [
    "maxPoints",
    "flight",
  ]

  maxPointsChanged(event) {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      var overLimit = flight.fare.points > this.maxPointsTarget.value;
      flightEle.hidden = overLimit;
    });
  }

  flightData(flightEle) {
    return this.flightsDataValue[flightEle.dataset.id];
  }

}
