import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flights"
export default class extends Controller {

  static values = {
    flightsData: Object,
  }
  static targets = [
    "maxPoints",
    "maxDepAt",
    "minDepAt",
    "flight",
  ]

  filterFlights() {
    this.flightTargets.forEach(flightEle => {
      var flight = this.flightData(flightEle);
      flightEle.hidden = this.failsFilters(flight);
    });
  }

  // Helpers.

  flightData(flightEle) {
    return this.flightsDataValue[flightEle.dataset.id];
  }

  failsFilters(flight) {
    if(this.failsMaxPoints(flight)) { return true }
    if(this.failsDepAt(flight))     { return true }
  }

  failsMaxPoints(flight) {
    if(this.maxPointsTarget.value) {
      return flight.fare.points > this.maxPointsTarget.value
    }
  }

  failsDepAt(flight) {
    var hour = (new Date(flight.dep_at)).getUTCHours();
    if(this.maxDepAtTarget.value) {
      return hour > this.maxDepAtTarget.value;
    }
    if(this.minDepAtTarget.value) {
      return hour < this.minDepAtTarget.value;
    }
  }

}
