import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flights"
export default class extends Controller {

  static values = {
    flightsData: Object,
  }
  static targets = [
    "maxPoints",
    "maxDepAt",
    "flight",
  ]

  maxPointsChanged() {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      var overLimit = flight.fare.points > this.maxPointsTarget.value;
      flightEle.hidden = overLimit;
    });
  }

  maxDepAtChanged() {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      var hour = (new Date(flight.dep_at)).getUTCHours();
      var overDepAt = hour > this.maxDepAtTarget.value;
      flightEle.hidden = overDepAt;
    });
  }

  // Helpers.

  flightData(flightEle) {
    return this.flightsDataValue[flightEle.dataset.id];
  }

}
