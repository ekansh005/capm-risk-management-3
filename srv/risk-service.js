const cds = require("@sap/cds");

module.exports = cds.service.impl(async function () {
  const bupa = await cds.connect.to("API_BUSINESS_PARTNER");
  this.on("READ", "Suppliers", async (req) => {
    return bupa.run(req.query);
  });
  this.after("READ", "Risks", (risksData) => {
    const risks = Array.isArray(risksData) ? risksData : [risksData];
    risks.forEach((risk) => {
      risk.criticality = risk.impact >= 100000 ? 1 : 2;
    });
  });
  // Risks?$expand=supplier
  this.on("READ", "Risks", async (req, next) => {
    if (!req.query.SELECT.columns) return next();

    const expandIndex = req.query.SELECT.columns.findIndex(({ expand, ref }) => expand && ref[0] === "supplier");
    if (expandIndex < 0) return next();

    // remove expand from query
    req.query.SELECT.columns.splice(expandIndex, 1);

    // make sure supplier_ID will be returned
    if (
      !req.query.SELECT.columns.indexOf("*") > 0 &&
      !req.query.SELECT.columns.find((column) => column.ref && column.ref.find((ref) => ref === "supplier_ID"))
    ) {
      req.query.SELECT.columns.push({ ref: ["supplier_ID"] });
    }

    const risks = await next();

    const asArray = (x) => (Array.isArray(x) ? x : [x]);

    // request all associated suppliers
    const supplierIds = asArray(risks).map((risk) => risk.supplier_ID);
    const suppliers = await bupa.run(SELECT.from("RiskService.Suppliers").where({ ID: supplierIds }));

    // convert in a map for easier lookup
    const supplierMap = {};
    for (const supplier of suppliers) {
      supplierMap[supplier.ID] = supplier;
    }

    // Add suppliers to result
    for (const note of asArray(risks)) {
      note.supplier = supplierMap[note.supplier_ID];
    }

    return risks;
  });
});
