const cds = require("@sap/cds");

module.exports = async function () {
  this.after("READ", "Risks", (risksData) => {
    const risks = Array.isArray(risksData) ? risksData : [risksData];
    risks.forEach((risk) => {
      risk.criticality = risk.impact >= 100000 ? 1 : 2;
    });
  });
};