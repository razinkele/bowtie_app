# =============================================================================
# Scientific Causal Knowledge Base for Environmental Bowtie Risk Analysis
# Version: 2.0.0
# Date: March 2026
#
# Encodes peer-reviewed causal connections between MSFD/DPSIR vocabulary items.
# Replaces keyword heuristics with scientifically defensible linkages.
#
# Sources:
#   Knights et al. (2015) - ODEMM impact chain framework
#   Borgwardt et al. (2019) - Cross-aquatic ecosystem assessment
#   Korpinen et al. (2021) - Combined effects on European marine ecosystems
#   HELCOM HOLAS 3 - Baltic Sea Pressure Index
#   MSFD Commission Decision (EU) 2017/848 - GES criteria
#   OSPAR QSR 2023 - Quality Status Report
#   Halpern et al. (2015) - Global cumulative human impact
#
# NOTE: All packages are loaded via global.R - do not add library() calls here
# =============================================================================

# =============================================================================
# REFERENCES
# =============================================================================

KB_REFERENCES <- data.frame(
  key = c(
    "knights_2015",
    "borgwardt_2019",
    "korpinen_2021",
    "halpern_2015",
    "helcom_holas3",
    "msfd_2017_848",
    "ospar_qsr_2023",
    "knights_2013",
    "judd_2015",
    "stelzenmuller_2018",
    "imo_bwm",
    "imo_marpol",
    "eu_cfs",
    "eu_uwwtd",
    "eu_nitrates",
    "imo_afs"
  ),
  authors = c(
    "Knights, A.M., Koss, R.S., Papadopoulou, N., Cooper, L.H., Robinson, L.A.",
    "Borgwardt, F., Robinson, L., Trauner, D., Teixeira, H., Nogueira, A.J.A. et al.",
    "Korpinen, S., Klancnik, K., Peterlin, M., Nurmi, M., Laamanen, L. et al.",
    "Halpern, B.S., Frazier, M., Potapenko, J., Casey, K.S., Koenig, K. et al.",
    "HELCOM",
    "European Commission",
    "OSPAR Commission",
    "Knights, A.M., Koss, R.S., Robinson, L.A.",
    "Judd, A.D., Backhaus, T., Goodsir, F.",
    "Stelzenmuller, V., Coll, M., Mazaris, A.D., Giakoumi, S., Katsanevakis, S. et al.",
    "International Maritime Organization",
    "International Maritime Organization",
    "European Parliament and Council",
    "European Council",
    "European Council",
    "International Maritime Organization"
  ),
  year = c(
    2015, 2019, 2021, 2015, 2023,
    2017, 2023, 2013, 2015, 2018,
    2017, 1973, 2013, 1991, 1991, 2001
  ),
  title = c(
    "Frontloading and Reign: Options for Delivering Ecosystem-based Marine Management",
    "Exploring variability in environmental impact risk from human activities across aquatic ecosystems",
    "Combined effects of human pressures on Europe's marine ecosystems",
    "Spatial and temporal changes in cumulative human impacts on the world's ocean",
    "HELCOM Holistic Assessment of the Baltic Sea 2023 (HOLAS 3)",
    "Commission Decision (EU) 2017/848 laying down criteria and methodological standards on good environmental status of marine waters",
    "Quality Status Report 2023",
    "Quantifying the effects of human pressures on marine ecosystems using the ODEMM framework",
    "An Environmental Risk Framework for Managing the Effects of Human Activities on the Marine Environment",
    "A risk-based approach to cumulative effect assessments for marine management",
    "International Convention for the Control and Management of Ships' Ballast Water and Sediments",
    "International Convention for the Prevention of Pollution from Ships (MARPOL)",
    "Regulation (EU) No 1380/2013 on the Common Fisheries Policy",
    "Council Directive 91/271/EEC concerning urban waste-water treatment",
    "Council Directive 91/676/EEC concerning the protection of waters against pollution caused by nitrates from agricultural sources",
    "International Convention on the Control of Harmful Anti-fouling Systems on Ships"
  ),
  journal = c(
    "ICES Journal of Marine Science",
    "Journal of Environmental Management",
    "Frontiers in Marine Science",
    "Nature Communications",
    "HELCOM",
    "Official Journal of the European Union",
    "OSPAR Commission",
    "Ecological Applications",
    "ICES Journal of Marine Science",
    "Science of the Total Environment",
    "IMO",
    "IMO",
    "Official Journal of the European Union",
    "Official Journal of the European Union",
    "Official Journal of the European Union",
    "IMO"
  ),
  doi = c(
    "10.1093/icesjms/fsv080",
    "10.1016/j.jenvman.2018.12.011",
    "10.3389/fmars.2021.671872",
    "10.1038/ncomms8615",
    "",
    "",
    "",
    "10.1890/12-0249.1",
    "10.1093/icesjms/fsu232",
    "10.1016/j.scitotenv.2017.06.025",
    "",
    "",
    "",
    "",
    "",
    ""
  ),
  url = c(
    "https://doi.org/10.1093/icesjms/fsv080",
    "https://doi.org/10.1016/j.jenvman.2018.12.011",
    "https://pmc.ncbi.nlm.nih.gov/articles/PMC8116428/",
    "https://www.nature.com/articles/ncomms8615",
    "https://helcom.fi/baltic-sea-trends/holistic-assessments/state-of-the-baltic-sea-2023/",
    "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0848",
    "https://oap.ospar.org/en/ospar-assessments/quality-status-reports/qsr-2023/",
    "https://doi.org/10.1890/12-0249.1",
    "https://doi.org/10.1093/icesjms/fsu232",
    "https://doi.org/10.1016/j.scitotenv.2017.06.025",
    "https://www.imo.org/en/ourwork/environment/pages/ballastwatermanagement.aspx",
    "https://www.imo.org/en/about/Conventions/Pages/International-Convention-for-the-Prevention-of-Pollution-from-Ships-(MARPOL).aspx",
    "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:32013R1380",
    "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:31991L0271",
    "https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=celex:31991L0676",
    "https://www.imo.org/en/ourwork/environment/pages/anti-fouling.aspx"
  ),
  stringsAsFactors = FALSE
)

# =============================================================================
# ACTIVITY -> PRESSURE CONNECTIONS
# Based on Knights et al. (2015), Borgwardt et al. (2019), Korpinen et al. (2021)
# =============================================================================

KB_ACTIVITY_PRESSURE <- data.frame(
  from_id = c(
    # A1: Physical restructuring (existing)
    "A1.1", "A1.1", "A1.2", "A1.2", "A1.3", "A1.3", "A1.3.1",
    "A1.4", "A1.4", "A1.5", "A1.5", "A1.5",
    # A1.3.2: Flood defence soft engineering (NEW)
    "A1.3.2", "A1.3.2",
    # A2: Extraction of non-living resources (existing)
    "A2.1", "A2.1", "A2.1", "A2.2", "A2.2", "A2.2", "A2.2",
    # A2.1.1: Coastal mining (NEW)
    "A2.1.1", "A2.1.1", "A2.1.1",
    # A2.3: Salt extraction (NEW)
    "A2.3", "A2.3",
    # A2.4: Water extraction (NEW)
    "A2.4",
    # A3: Energy production (existing)
    "A3.1", "A3.1", "A3.1", "A3.1", "A3.1", "A3.2", "A3.2", "A3.2",
    # A3.3: Cables (NEW)
    "A3.3", "A3.3",
    # A4: Extraction of living resources (existing)
    "A4.1", "A4.1", "A4.1", "A4.1", "A4.1", "A4.1",
    # A4.2: Fish processing (NEW)
    "A4.2", "A4.2",
    "A4.3", "A4.4", "A4.4",
    # A5: Cultivation (existing)
    "A5.1", "A5.1", "A5.1", "A5.1", "A5.1", "A5.1",
    # A5.2: Freshwater aquaculture (NEW)
    "A5.2", "A5.2", "A5.2", "A5.2",
    "A5.3", "A5.3", "A5.3", "A5.3",
    "A5.3.1", "A5.3.2", "A5.3.3",
    "A5.3.4", "A5.3.4",
    # A5.4: Forestry (NEW)
    "A5.4", "A5.4",
    "A5.4.1", "A5.4.1",
    # A6: Transport (existing)
    "A6.1", "A6.1", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2",
    # A6.3: Air transport (NEW)
    "A6.3", "A6.3",
    # A6.4: Land transport (NEW)
    "A6.4", "A6.4", "A6.4",
    # A7: Urban and industrial (existing)
    "A7.1", "A7.1", "A7.1", "A7.1",
    "A7.2", "A7.2", "A7.2", "A7.2",
    "A7.3", "A7.3", "A7.3",
    # A8: Tourism (existing)
    "A8.1", "A8.1", "A8.2", "A8.2", "A8.2",
    # A8.2 + A4.1: Local recreation (NEW - only P1.6 unique)
    "A8.2",
    # A9: Security/Defence (existing)
    "A9.1", "A9.1",
    # A9.2: Research activities (NEW)
    "A9.2", "A9.2"
  ),
  to_id = c(
    # A1: Physical restructuring -> Pressures (existing)
    "P2.2", "P2.3", "P2.3", "P2.1", "P2.2", "P2.3", "P2.2",
    "P2.2", "P3.5", "P2.1", "P2.2", "P3.2.1",
    # A1.3.2 -> Pressures (NEW)
    "P2.1", "P2.3",
    # A2 -> Pressures (existing)
    "P2.2", "P2.1", "P3.2.1", "P3.3", "P2.1", "P3.5", "P2.2",
    # A2.1.1 -> Pressures (NEW)
    "P2.2", "P2.1", "P3.2.1",
    # A2.3 -> Pressures (NEW)
    "P2.1", "P3.7",
    # A2.4 -> Pressures (NEW)
    "P2.3",
    # A3 -> Pressures (existing)
    "P3.5", "P2.2", "P1.5", "P3.6", "P2.1", "P3.3", "P3.6", "P3.1",
    # A3.3 -> Pressures (NEW)
    "P2.1", "P3.6",
    # A4 -> Pressures (existing)
    "P1.6", "P2.1", "P1.5", "P3.4", "P1.1", "P3.5",
    # A4.2 -> Pressures (NEW)
    "P3.3", "P3.2",
    "P1.6", "P1.6", "P1.5",
    # A5 -> Pressures (existing)
    "P3.1", "P3.2", "P3.3", "P1.1", "P1.2", "P1.4",
    # A5.2 -> Pressures (NEW)
    "P3.1", "P3.2", "P3.3", "P1.2",
    "P3.1", "P3.3", "P3.2.1", "P3.4",
    "P3.3", "P3.1", "P3.1",
    "P2.3", "P3.2.1",
    # A5.4 -> Pressures (NEW)
    "P3.2.1", "P2.3",
    "P3.2.1", "P2.3",
    # A6 -> Pressures (existing)
    "P2.2", "P2.1", "P3.5", "P3.3", "P1.1", "P3.4", "P3.6", "P1.5", "P2.1",
    # A6.3 -> Pressures (NEW)
    "P3.5", "P3.3",
    # A6.4 -> Pressures (NEW)
    "P3.3", "P3.5", "P3.4",
    # A7 -> Pressures (existing)
    "P3.1", "P3.4", "P3.6", "P3.3",
    "P3.3", "P3.1", "P3.6", "P3.7",
    "P3.3", "P3.1", "P3.4",
    # A8 -> Pressures (existing)
    "P2.2", "P3.4", "P1.5", "P3.4", "P3.5",
    # A8.2 local recreation (NEW - only P1.6 unique)
    "P1.6",
    # A9 -> Pressures (existing)
    "P3.5", "P3.3",
    # A9.2 -> Pressures (NEW)
    "P1.5", "P2.1"
  ),
  confidence = c(
    # A1 (existing)
    "HIGH", "HIGH", "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH",
    "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH",
    # A1.3.2 (NEW)
    "MEDIUM", "MEDIUM",
    # A2 (existing)
    "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A2.1.1 (NEW)
    "HIGH", "HIGH", "HIGH",
    # A2.3 (NEW)
    "MEDIUM", "MEDIUM",
    # A2.4 (NEW)
    "MEDIUM",
    # A3 (existing)
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "HIGH", "HIGH", "MEDIUM",
    # A3.3 (NEW)
    "MEDIUM", "MEDIUM",
    # A4 (existing)
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A4.2 (NEW)
    "MEDIUM", "MEDIUM",
    "HIGH", "HIGH", "MEDIUM",
    # A5 (existing)
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A5.2 (NEW)
    "HIGH", "HIGH", "MEDIUM", "MEDIUM",
    "HIGH", "HIGH", "HIGH", "MEDIUM",
    "HIGH", "HIGH", "HIGH",
    "MEDIUM", "HIGH",
    # A5.4 (NEW)
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    # A6 (existing)
    "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A6.3 (NEW)
    "LOW", "MEDIUM",
    # A6.4 (NEW)
    "MEDIUM", "MEDIUM", "MEDIUM",
    # A7 (existing)
    "HIGH", "HIGH", "MEDIUM", "HIGH",
    "HIGH", "MEDIUM", "HIGH", "MEDIUM",
    "HIGH", "HIGH", "HIGH",
    # A8 (existing)
    "MEDIUM", "MEDIUM", "MEDIUM", "MEDIUM", "LOW",
    # A8.2 local recreation (NEW)
    "LOW",
    # A9 (existing)
    "HIGH", "MEDIUM",
    # A9.2 (NEW)
    "LOW", "LOW"
  ),
  msfd_descriptor = c(
    # A1 (existing)
    "D6", "D7", "D7", "D6", "D6", "D7", "D6",
    "D6", "D11", "D6", "D6", "D6",
    # A1.3.2 (NEW)
    "D6", "D7",
    # A2 (existing)
    "D6", "D6", "D6", "D8", "D6", "D11", "D6",
    # A2.1.1 (NEW)
    "D6", "D6", "D6",
    # A2.3 (NEW)
    "D6", "D7",
    # A2.4 (NEW)
    "D7",
    # A3 (existing)
    "D11", "D6", "D1", "D11", "D6", "D8", "D11", "D5",
    # A3.3 (NEW)
    "D6", "D11",
    # A4 (existing)
    "D3", "D6", "D1", "D10", "D2", "D11",
    # A4.2 (NEW)
    "D8", "D5",
    "D3", "D3", "D1",
    # A5 (existing)
    "D5", "D5", "D8", "D2", "D1", "D1",
    # A5.2 (NEW)
    "D5", "D5", "D8", "D1",
    "D5", "D8", "D5", "D10",
    "D8", "D5", "D5",
    "D7", "D6",
    # A5.4 (NEW)
    "D6", "D7",
    "D6", "D7",
    # A6 (existing)
    "D6", "D6", "D11", "D8", "D2", "D10", "D11", "D1", "D6",
    # A6.3 (NEW)
    "D11", "D8",
    # A6.4 (NEW)
    "D8", "D11", "D10",
    # A7 (existing)
    "D5", "D10", "D11", "D8",
    "D8", "D5", "D11", "D7",
    "D8", "D5", "D10",
    # A8 (existing)
    "D6", "D10", "D1", "D10", "D11",
    # A8.2 local recreation (NEW)
    "D3",
    # A9 (existing)
    "D11", "D8",
    # A9.2 (NEW)
    "D1", "D6"
  ),
  mechanism = c(
    # A1: Physical restructuring (existing)
    "Permanent habitat conversion through land claim",
    "Altered tidal prism and flow patterns from land claim",
    "Modified river flow regimes and sediment transport",
    "Temporary disturbance from channel modification works",
    "Permanent seabed/coastline alteration by hard structures",
    "Changed wave exposure and sediment dynamics",
    "Sealing of seabed under hard structures (seawalls, breakwaters)",
    "Foundation footprint causes permanent habitat loss",
    "Construction noise from offshore installation works",
    "Direct sediment removal and redistribution",
    "Extraction of seabed substrate causes permanent habitat loss",
    "Sediment plumes from dredging and disposal operations",
    # A1.3.2 (NEW)
    "Beach nourishment and managed realignment disturb seabed sediments",
    "Soft engineering alters nearshore hydrodynamics and sediment transport",
    # A2: Extraction (existing)
    "Substrate removal from mineral extraction",
    "Seabed disturbance during extraction operations",
    "Sediment plumes from extraction activities",
    "Produced water, drilling muds, and accidental spills",
    "Seabed disturbance from drilling and platform operations",
    "Seismic surveys and operational noise",
    "Platform foundation footprint",
    # A2.1.1 (NEW)
    "Coastal aggregate extraction causes permanent substrate removal",
    "Coastal mining operations physically disturb seabed and nearshore habitats",
    "Coastal mining generates sediment plumes that smother benthic communities",
    # A2.3 (NEW)
    "Salt extraction brine discharge alters seabed through subsidence",
    "Salt production releases concentrated brine effluent to coastal waters",
    # A2.4 (NEW)
    "Water abstraction alters river flow regimes and estuarine salinity gradients",
    # A3: Energy (existing)
    "Pile driving during construction of wind/tidal infrastructure",
    "Foundation footprint of energy structures on seabed",
    "Collision risk for birds, barrier effects, displacement",
    "Electromagnetic fields from subsea cables",
    "Temporary seabed disturbance during cable laying",
    "Discharge of contaminants from non-renewable energy processes",
    "Thermal discharge from cooling water outfalls",
    "Atmospheric deposition of combustion products (NOx, SOx)",
    # A3.3 (NEW)
    "Cable installation and maintenance causes seabed disturbance along route",
    "Electromagnetic fields from submarine power/telecom cables affect fauna",
    # A4: Living resource extraction (existing)
    "Direct removal of target fish/shellfish species",
    "Bottom trawling causes seabed abrasion",
    "Disturbance of marine species during fishing operations",
    "Discarded/lost fishing gear (ghost fishing, marine litter)",
    "Transport of non-indigenous species via fishing vessels",
    "Vessel noise during fishing operations",
    # A4.2 (NEW)
    "Fish processing discharge contains heavy metals and processing chemicals",
    "Fish processing waste contributes organic loading to receiving waters",
    "Harvesting of marine plants alters community structure",
    "Extraction of non-target wild species",
    "Disturbance to species at breeding/resting sites from hunting",
    # A5: Cultivation (existing)
    "Fish farm waste: excess feed, excreta release N and P",
    "Organic loading from uneaten feed and faecal matter",
    "Antibiotics, antifoulants, pesticides from fish farms",
    "Escape of farmed species; pathogen transfer to wild stocks",
    "Disease amplification in high-density culture conditions",
    "Replacement of natural communities by cultured species",
    # A5.2 (NEW)
    "Freshwater aquaculture effluent releases nitrogen and phosphorus",
    "Freshwater fish farm organic waste degrades downstream water quality",
    "Freshwater aquaculture uses antibiotics and antifungal chemicals",
    "Freshwater aquaculture facilitates pathogen transfer to wild populations",
    "Fertilizer N and P runoff via rivers to coastal waters",
    "Pesticide and herbicide runoff from agricultural land",
    "Soil erosion from agricultural land enters water courses",
    "Plastic mulch, packaging waste from agricultural operations",
    "Biocide application contaminates water courses",
    "Nitrogen fertilizer runoff causes nutrient enrichment",
    "Phosphorus fertilizer runoff causes nutrient enrichment",
    "Land drainage alters hydrological regime",
    "Soil erosion from agricultural land use changes",
    # A5.4 (NEW)
    "Forestry operations cause soil erosion and sediment runoff to water courses",
    "Deforestation and clear-cutting alter catchment hydrology and runoff patterns",
    "Soil erosion from clear-cutting enters water courses",
    "Changed runoff patterns from deforestation",
    # A6: Transport (existing)
    "Port construction causes permanent habitat loss",
    "Seabed disturbance from port maintenance dredging",
    "Continuous engine and propeller noise from shipping",
    "Antifouling paints, fuel spills, operational discharges",
    "Ballast water and hull fouling transfer organisms",
    "Operational and accidental waste discharge at sea",
    "Light pollution from port and vessel operations",
    "Visual and acoustic disturbance to wildlife from vessels",
    "Anchor scour and propeller wash in shallow areas",
    # A6.3 (NEW)
    "Aircraft noise disturbs marine and coastal wildlife near airports and flight paths",
    "Aircraft emissions contribute atmospheric contaminants via deposition",
    # A6.4 (NEW)
    "Road runoff carries heavy metals, hydrocarbons, and de-icing chemicals to coast",
    "Road and rail traffic noise propagates to coastal and estuarine habitats",
    "Road and rail infrastructure generates litter and debris near coastal areas",
    # A7: Urban and industrial (existing)
    "Urban sewage and stormwater carry nutrients to coast",
    "Solid waste and litter from urban areas",
    "Artificial light from coastal urban areas",
    "Urban runoff carries contaminants (hydrocarbons, metals)",
    "Industrial discharge of hazardous chemical substances",
    "Industrial wastewater nutrient content",
    "Thermal and noise emissions from industrial facilities",
    "Industrial cooling water and process water discharge",
    "Waste treatment discharge of residual contaminants",
    "Nutrient content in treated wastewater effluent",
    "Solid waste and litter from waste treatment facilities",
    # A8: Tourism (existing)
    "Coastal tourism infrastructure development on seabed",
    "Litter from tourism facilities and beach use",
    "Human presence disturbs wildlife at breeding/resting sites",
    "Marine litter from recreational boating and beach use",
    "Recreational vessel engine noise in coastal waters",
    # A8.2 local recreation (NEW)
    "Recreational angling causes extraction of wild fish species",
    # A9: Security (existing)
    "Military sonar, explosions, and vessel operations",
    "Munitions residues and military-related contaminants",
    # A9.2 (NEW)
    "Scientific sampling and monitoring causes minor disturbance to species",
    "Research vessel operations and equipment deployment disturb seabed"
  ),
  citation = c(
    # A1 (existing)
    rep("knights_2015", 7), rep("borgwardt_2019", 5),
    # A1.3.2 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    # A2 (existing)
    rep("borgwardt_2019", 3), rep("knights_2015", 4),
    # A2.1.1 (NEW)
    "borgwardt_2019", "borgwardt_2019", "borgwardt_2019",
    # A2.3 (NEW)
    "korpinen_2021", "korpinen_2021",
    # A2.4 (NEW)
    "korpinen_2021",
    # A3 (existing)
    rep("borgwardt_2019", 5), rep("korpinen_2021", 3),
    # A3.3 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    # A4 (existing)
    rep("knights_2015", 6),
    # A4.2 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("borgwardt_2019", 3),
    # A5 (existing)
    rep("borgwardt_2019", 6),
    # A5.2 (NEW)
    "borgwardt_2019", "borgwardt_2019", "borgwardt_2019", "borgwardt_2019",
    rep("korpinen_2021", 4),
    rep("knights_2015", 3),
    rep("borgwardt_2019", 2),
    # A5.4 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("korpinen_2021", 2),
    # A6 (existing)
    rep("knights_2015", 4), "imo_bwm", rep("imo_marpol", 2), rep("borgwardt_2019", 2),
    # A6.3 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    # A6.4 (NEW)
    "korpinen_2021", "korpinen_2021", "korpinen_2021",
    # A7 (existing)
    rep("korpinen_2021", 4),
    rep("knights_2015", 4),
    rep("borgwardt_2019", 3),
    # A8 (existing)
    rep("borgwardt_2019", 5),
    # A8.2 local recreation (NEW)
    "borgwardt_2019",
    # A9 (existing)
    rep("knights_2015", 2),
    # A9.2 (NEW)
    "borgwardt_2019", "borgwardt_2019"
  ),
  # ODEMM risk scoring columns (Knights et al. 2015, 5-criteria framework)
  spatial_extent = c(
    # A1 (existing): 1=site, 2=local, 3=subregional, 4=regional, 5=widespread
    3, 3, 3, 2, 3, 3, 2,
    2, 3, 2, 2, 3,
    # A1.3.2 (NEW)
    2, 2,
    # A2 (existing)
    2, 2, 3, 3, 2, 3, 2,
    # A2.1.1 (NEW)
    2, 2, 3,
    # A2.3 (NEW)
    2, 2,
    # A2.4 (NEW)
    3,
    # A3 (existing)
    3, 2, 4, 3, 2, 3, 2, 4,
    # A3.3 (NEW)
    2, 2,
    # A4 (existing)
    4, 4, 4, 4, 3, 4,
    # A4.2 (NEW)
    2, 2,
    3, 3, 2,
    # A5 (existing)
    2, 2, 2, 2, 2, 2,
    # A5.2 (NEW)
    2, 2, 2, 2,
    4, 4, 3, 3,
    3, 3, 3,
    3, 3,
    # A5.4 (NEW)
    3, 3,
    3, 3,
    # A6 (existing)
    2, 2, 4, 4, 4, 4, 3, 3, 2,
    # A6.3 (NEW)
    3, 3,
    # A6.4 (NEW)
    3, 3, 3,
    # A7 (existing)
    3, 3, 2, 3,
    3, 2, 2, 2,
    2, 2, 2,
    # A8 (existing)
    2, 2, 2, 2, 2,
    # A8.2 local recreation (NEW)
    1,
    # A9 (existing)
    3, 3,
    # A9.2 (NEW)
    1, 1
  ),
  frequency = c(
    # A1 (existing): 1=rare, 2=occasional, 3=seasonal, 4=regular, 5=continuous
    2, 2, 4, 3, 2, 2, 2,
    2, 2, 3, 3, 3,
    # A1.3.2 (NEW)
    2, 2,
    # A2 (existing)
    4, 4, 4, 4, 4, 3, 2,
    # A2.1.1 (NEW)
    4, 4, 4,
    # A2.3 (NEW)
    5, 5,
    # A2.4 (NEW)
    5,
    # A3 (existing)
    2, 2, 5, 5, 2, 5, 5, 5,
    # A3.3 (NEW)
    2, 5,
    # A4 (existing)
    5, 5, 5, 5, 3, 5,
    # A4.2 (NEW)
    5, 5,
    4, 3, 3,
    # A5 (existing)
    5, 5, 5, 3, 4, 5,
    # A5.2 (NEW)
    5, 5, 4, 4,
    5, 5, 4, 4,
    5, 5, 5,
    4, 3,
    # A5.4 (NEW)
    3, 3,
    3, 3,
    # A6 (existing)
    2, 3, 5, 5, 5, 5, 5, 5, 4,
    # A6.3 (NEW)
    5, 5,
    # A6.4 (NEW)
    5, 5, 5,
    # A7 (existing)
    5, 5, 5, 5,
    5, 5, 5, 5,
    5, 5, 5,
    # A8 (existing)
    2, 3, 3, 3, 3,
    # A8.2 local recreation (NEW)
    3,
    # A9 (existing)
    2, 2,
    # A9.2 (NEW)
    2, 2
  ),
  persistence = c(
    # A1 (existing): 1=<1yr, 2=1-5yr, 3=5-15yr, 4=15-25yr, 5=>25yr
    5, 4, 3, 2, 5, 4, 5,
    5, 1, 2, 5, 1,
    # A1.3.2 (NEW)
    2, 2,
    # A2 (existing)
    5, 2, 1, 3, 2, 1, 5,
    # A2.1.1 (NEW)
    5, 2, 1,
    # A2.3 (NEW)
    2, 3,
    # A2.4 (NEW)
    3,
    # A3 (existing)
    1, 5, 3, 1, 2, 4, 1, 3,
    # A3.3 (NEW)
    2, 1,
    # A4 (existing)
    3, 2, 1, 4, 3, 1,
    # A4.2 (NEW)
    2, 2,
    3, 3, 1,
    # A5 (existing)
    2, 2, 3, 3, 2, 3,
    # A5.2 (NEW)
    2, 2, 3, 2,
    3, 4, 2, 3,
    4, 3, 3,
    3, 2,
    # A5.4 (NEW)
    2, 3,
    2, 3,
    # A6 (existing)
    5, 2, 1, 3, 3, 3, 1, 1, 2,
    # A6.3 (NEW)
    1, 2,
    # A6.4 (NEW)
    2, 1, 3,
    # A7 (existing)
    3, 4, 1, 3,
    4, 3, 1, 3,
    3, 3, 4,
    # A8 (existing)
    5, 3, 1, 3, 1,
    # A8.2 local recreation (NEW)
    2,
    # A9 (existing)
    1, 4,
    # A9.2 (NEW)
    1, 1
  ),
  severity = c(
    # A1 (existing): 1=negligible, 2=minor, 3=moderate, 4=severe, 5=catastrophic
    4, 3, 3, 2, 4, 3, 4,
    4, 3, 3, 4, 3,
    # A1.3.2 (NEW)
    2, 2,
    # A2 (existing)
    4, 3, 3, 4, 3, 3, 3,
    # A2.1.1 (NEW)
    4, 3, 3,
    # A2.3 (NEW)
    2, 3,
    # A2.4 (NEW)
    3,
    # A3 (existing)
    3, 3, 3, 2, 2, 3, 2, 3,
    # A3.3 (NEW)
    2, 2,
    # A4 (existing)
    4, 3, 2, 3, 3, 3,
    # A4.2 (NEW)
    3, 3,
    3, 3, 2,
    # A5 (existing)
    3, 3, 3, 3, 3, 3,
    # A5.2 (NEW)
    3, 3, 3, 3,
    4, 4, 3, 3,
    4, 3, 3,
    3, 3,
    # A5.4 (NEW)
    3, 3,
    3, 3,
    # A6 (existing)
    4, 3, 3, 4, 4, 3, 2, 2, 2,
    # A6.3 (NEW)
    2, 2,
    # A6.4 (NEW)
    3, 2, 2,
    # A7 (existing)
    3, 3, 2, 3,
    4, 3, 2, 3,
    3, 3, 3,
    # A8 (existing)
    3, 2, 2, 2, 2,
    # A8.2 local recreation (NEW)
    2,
    # A9 (existing)
    4, 3,
    # A9.2 (NEW)
    1, 1
  ),
  stringsAsFactors = FALSE
)

# Compute numeric confidence scores
KB_ACTIVITY_PRESSURE$confidence_score <- ifelse(
  KB_ACTIVITY_PRESSURE$confidence == "HIGH", 0.85,
  ifelse(KB_ACTIVITY_PRESSURE$confidence == "MEDIUM", 0.70, 0.50)
)

# =============================================================================
# PRESSURE -> CONSEQUENCE CONNECTIONS
# Based on MSFD descriptor-state linkages, Korpinen et al. (2021)
# =============================================================================

KB_PRESSURE_CONSEQUENCE <- data.frame(
  from_id = c(
    # P1: Biological pressures (existing)
    "P1.1", "P1.1", "P1.1",
    # P1.1 (NEW)
    "P1.1", "P1.1",
    "P1.2", "P1.2",
    # P1.3: GMO/translocation (NEW)
    "P1.3", "P1.3",
    "P1.4", "P1.4",
    "P1.5", "P1.5",
    "P1.6", "P1.6", "P1.6", "P1.6", "P1.6",
    # P1.6 (NEW)
    "P1.6", "P1.6",
    # P2: Physical pressures (existing)
    "P2.1", "P2.1",
    # P2.1 (NEW)
    "P2.1",
    "P2.2", "P2.2", "P2.2",
    # P2.2 (NEW)
    "P2.2", "P2.2",
    "P2.3", "P2.3", "P2.3",
    # P2.4: New habitat creation (NEW)
    "P2.4", "P2.4",
    # P3: Substances, litter, energy (existing)
    "P3.1", "P3.1", "P3.1", "P3.1", "P3.1",
    # P3.1 (NEW)
    "P3.1", "P3.1",
    "P3.2", "P3.2",
    # P3.2.1: Sediments/erosion (NEW)
    "P3.2.1", "P3.2.1",
    "P3.3", "P3.3", "P3.3", "P3.3",
    # P3.3 (NEW)
    "P3.3", "P3.3",
    "P3.4", "P3.4", "P3.4",
    # P3.4 (NEW)
    "P3.4", "P3.4",
    "P3.5", "P3.5",
    # P3.5 (NEW)
    "P3.5", "P3.5",
    "P3.6", "P3.6",
    # P3.7: Brine input (NEW)
    "P3.7",
    # P4: Climate change indicators (existing)
    "P4.3(indicator)", "P4.3(indicator)"
  ),
  to_id = c(
    # P1.1 Non-indigenous species (existing)
    "C1.1", "C1.2", "C2.2",
    # P1.1 (NEW)
    "C1.5", "C2.1",
    # P1.2 Pathogens (existing)
    "C1.2.1", "C3.2",
    # P1.3 (NEW)
    "C1.1", "C1.2.3",
    # P1.4 Cultivation changes (existing)
    "C1.1", "C1.2",
    # P1.5 Disturbance (existing)
    "C1.1", "C3.1",
    # P1.6 Extraction/mortality (existing)
    "C1.2.1", "C1.1", "C2.2", "C2.5", "C1.2.3",
    # P1.6 (NEW)
    "C2.4", "C3.4",
    # P2.1 Physical disturbance (existing)
    "C1.1", "C1.4",
    # P2.1 (NEW)
    "C2.5",
    # P2.2 Physical loss (existing)
    "C1.1", "C1.4", "C1.3.2",
    # P2.2 (NEW)
    "C2.1", "C2.5",
    # P2.3 Hydrological changes (existing)
    "C1.1", "C1.3.2", "C1.4",
    # P2.4 (NEW)
    "C1.1", "C1.4",
    # P3.1 Nutrients (existing)
    "C1.1", "C1.2.4", "C1.3.3", "C3.2", "C2.5",
    # P3.1 (NEW)
    "C1.2.2", "C1.3.1",
    # P3.2 Organic matter (existing)
    "C1.1", "C1.2.4",
    # P3.2.1 (NEW)
    "C1.1", "C1.2.4",
    # P3.3 Hazardous substances (existing)
    "C3.2", "C1.1", "C1.2.1", "C2.3",
    # P3.3 (NEW)
    "C1.5", "C2.1",
    # P3.4 Litter (existing)
    "C1.1", "C3.1", "C2.5",
    # P3.4 (NEW)
    "C3.3", "C3.5",
    # P3.5 Sound (existing)
    "C1.1", "C3.1",
    # P3.5 (NEW)
    "C2.6", "C3.4",
    # P3.6 Other energy (existing)
    "C1.1", "C3.1",
    # P3.7 (NEW)
    "C1.1",
    # P4 Climate (existing)
    "C1.3.2", "C1.1"
  ),
  confidence = c(
    # P1.1 (existing)
    "HIGH", "MEDIUM", "MEDIUM",
    # P1.1 (NEW)
    "MEDIUM", "MEDIUM",
    # P1.2 (existing)
    "HIGH", "HIGH",
    # P1.3 (NEW)
    "MEDIUM", "MEDIUM",
    # P1.4 (existing)
    "HIGH", "MEDIUM",
    # P1.5 (existing)
    "MEDIUM", "MEDIUM",
    # P1.6 (existing)
    "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM",
    # P1.6 (NEW)
    "MEDIUM", "MEDIUM",
    # P2.1 (existing)
    "HIGH", "MEDIUM",
    # P2.1 (NEW)
    "MEDIUM",
    # P2.2 (existing)
    "HIGH", "HIGH", "MEDIUM",
    # P2.2 (NEW)
    "MEDIUM", "MEDIUM",
    # P2.3 (existing)
    "MEDIUM", "MEDIUM", "MEDIUM",
    # P2.4 (NEW)
    "LOW", "LOW",
    # P3.1 (existing)
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM",
    # P3.1 (NEW)
    "MEDIUM", "MEDIUM",
    # P3.2 (existing)
    "HIGH", "HIGH",
    # P3.2.1 (NEW)
    "HIGH", "HIGH",
    # P3.3 (existing)
    "HIGH", "HIGH", "HIGH", "HIGH",
    # P3.3 (NEW)
    "MEDIUM", "MEDIUM",
    # P3.4 (existing)
    "HIGH", "MEDIUM", "MEDIUM",
    # P3.4 (NEW)
    "MEDIUM", "LOW",
    # P3.5 (existing)
    "HIGH", "MEDIUM",
    # P3.5 (NEW)
    "MEDIUM", "LOW",
    # P3.6 (existing)
    "MEDIUM", "MEDIUM",
    # P3.7 (NEW)
    "MEDIUM",
    # P4 (existing)
    "HIGH", "HIGH"
  ),
  msfd_descriptor = c(
    "D2", "D2", "D2",
    # P1.1 (NEW)
    "D2", "D2",
    "D1", "D9",
    # P1.3 (NEW)
    "D2", "D2",
    "D1", "D1",
    "D1", "D1",
    "D3", "D4", "D3", "D3", "D1",
    # P1.6 (NEW)
    "D3", "D3",
    "D6", "D6",
    # P2.1 (NEW)
    "D6",
    "D6", "D6", "D6",
    # P2.2 (NEW)
    "D6", "D6",
    "D7", "D7", "D7",
    # P2.4 (NEW)
    "D6", "D6",
    "D5", "D5", "D5", "D5", "D5",
    # P3.1 (NEW)
    "D5", "D5",
    "D5", "D5",
    # P3.2.1 (NEW)
    "D6", "D5",
    "D8", "D8", "D8", "D8",
    # P3.3 (NEW)
    "D8", "D8",
    "D10", "D10", "D10",
    # P3.4 (NEW)
    "D10", "D10",
    "D11", "D11",
    # P3.5 (NEW)
    "D11", "D11",
    "D11", "D11",
    # P3.7 (NEW)
    "D7",
    "D7", "D1"
  ),
  mechanism = c(
    # P1.1 (existing)
    "Invasive species alter ecosystem structure and function",
    "Invasive species outcompete native species, reducing provisioning services",
    "Invasive species reduce economic value of fisheries and aquaculture",
    # P1.1 (NEW)
    "Invasive species require new governance frameworks for management and control",
    "Invasive species management and eradication programmes impose significant costs",
    # P1.2 (existing)
    "Pathogens cause disease and mortality in fish and shellfish stocks",
    "Microbial contamination threatens human health via seafood and bathing water",
    # P1.3 (NEW)
    "Translocated organisms and GMOs alter local community structure and genetics",
    "Genetic introgression from translocated species reduces wild population diversity",
    # P1.4 (existing)
    "Monoculture replaces natural biodiversity in cultivation areas",
    "Altered species composition reduces ecosystem service provision",
    # P1.5 (existing)
    "Repeated disturbance causes species displacement and behavioral change",
    "Loss of undisturbed natural areas reduces aesthetic and recreational value",
    # P1.6 (existing)
    "Overharvesting depletes commercial fish and shellfish stocks",
    "Removal of key species disrupts food web structure and function",
    "Stock depletion reduces fishery income and economic value",
    "Depleted stocks undermine blue economy sectors",
    "Bycatch threatens genetic diversity of non-target species",
    # P1.6 (NEW)
    "Fishing industry decline reduces employment and labor market opportunities",
    "Loss of traditional fishing practices erodes maritime cultural heritage",
    # P2.1 (existing)
    "Seabed disturbance damages benthic communities and habitats",
    "Physical disturbance alters seabed landscape and natural features",
    # P2.1 (NEW)
    "Physical disturbance degrades marine areas important for blue economy activities",
    # P2.2 (existing)
    "Permanent habitat loss eliminates associated biological communities",
    "Permanent substrate change alters landscape character",
    "Loss of natural coastal structures reduces storm protection",
    # P2.2 (NEW)
    "Habitat loss requires costly restoration and compensatory measures",
    "Permanent habitat loss removes areas essential for blue economy sectors",
    # P2.3 (existing)
    "Altered currents and salinity regimes shift species distributions",
    "Changed hydrodynamics reduce natural hazard buffering capacity",
    "Modified water flow patterns alter landscape and seascape character",
    # P2.4 (NEW)
    "New artificial habitat may attract different species assemblages than natural habitat",
    "Artificial habitat creation alters local landscape and seascape character",
    # P3.1 (existing)
    "Eutrophication: excess nutrients fuel harmful algal blooms",
    "Algal blooms and hypoxia degrade water quality for supply purposes",
    "Decomposition of algal biomass consumes oxygen, impairing waste breakdown",
    "Harmful algal blooms and hypoxia threaten human health",
    "Eutrophication degrades coastal waters critical for blue economy",
    # P3.1 (NEW)
    "Nutrient enrichment reduces algae provisioning services through toxic bloom dominance",
    "Eutrophication impairs ocean carbon sequestration and climate regulation capacity",
    # P3.2 (existing)
    "Organic enrichment leads to hypoxia and community shifts",
    "Oxygen depletion from organic matter degrades water quality",
    # P3.2.1 (NEW)
    "Excessive sedimentation smothers benthic communities and alters habitat structure",
    "Sediment loading reduces water clarity and degrades water quality for provisioning",
    # P3.3 (existing)
    "Bioaccumulation of contaminants threatens human health via seafood",
    "Toxic substances cause mortality and sublethal effects in marine life",
    "Contaminants impair reproduction and growth in fish and shellfish",
    "Contamination reduces economic value of marine resources",
    # P3.3 (NEW)
    "Contamination triggers regulatory responses and governance requirements",
    "Contaminated sites require costly remediation and monitoring programmes",
    # P3.4 (existing)
    "Ingestion and entanglement cause mortality across marine taxa",
    "Marine litter degrades visual quality of coastal environments",
    "Litter-affected areas lose tourism and recreational appeal",
    # P3.4 (NEW)
    "Marine litter degrades sense of place and community connection to coast",
    "Visible pollution changes public perception of marine environment quality",
    # P3.5 (existing)
    "Anthropogenic noise displaces marine mammals, masks communication",
    "Underwater noise degrades acoustic quality of marine environment",
    # P3.5 (NEW)
    "Noise disturbance reduces viability of noise-sensitive economic activities",
    "Persistent noise pollution erodes cultural connection to tranquil coastal settings",
    # P3.6 (existing)
    "Thermal discharge and light pollution alter local communities",
    "Artificial light and thermal plumes degrade environmental aesthetics",
    # P3.7 (NEW)
    "Brine discharge alters local salinity and causes osmotic stress on benthic biota",
    # P4 (existing)
    "Sea level rise and storm surges damage coastal protection infrastructure",
    "Climate-driven temperature and acidification shifts alter ecosystems"
  ),
  citation = c(
    rep("korpinen_2021", 3),
    # P1.1 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("msfd_2017_848", 2),
    # P1.3 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    rep("borgwardt_2019", 2),
    rep("borgwardt_2019", 2),
    rep("knights_2015", 5),
    # P1.6 (NEW)
    "knights_2015", "knights_2015",
    rep("korpinen_2021", 2),
    # P2.1 (NEW)
    "korpinen_2021",
    rep("korpinen_2021", 3),
    # P2.2 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("borgwardt_2019", 3),
    # P2.4 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    rep("korpinen_2021", 5),
    # P3.1 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("korpinen_2021", 2),
    # P3.2.1 (NEW)
    "korpinen_2021", "korpinen_2021",
    rep("msfd_2017_848", 4),
    # P3.3 (NEW)
    "msfd_2017_848", "msfd_2017_848",
    rep("halpern_2015", 3),
    # P3.4 (NEW)
    "halpern_2015", "halpern_2015",
    rep("msfd_2017_848", 2),
    # P3.5 (NEW)
    "msfd_2017_848", "msfd_2017_848",
    rep("borgwardt_2019", 2),
    # P3.7 (NEW)
    "korpinen_2021",
    rep("korpinen_2021", 2)
  ),
  # Recovery time and reversibility columns
  recovery_years_min = c(
    # P1.1 (existing 3 + NEW 2)
    999, 999, 999, 999, 999,
    # P1.2 (existing 2)
    1, 1,
    # P1.3 (NEW 2)
    10, 10,
    # P1.4 (existing 2)
    5, 5,
    # P1.5 (existing 2)
    1, 1,
    # P1.6 (existing 5 + NEW 2)
    5, 5, 5, 5, 5, 5, 5,
    # P2.1 (existing 2 + NEW 1)
    2, 2, 2,
    # P2.2 (existing 3 + NEW 2)
    50, 50, 50, 50, 50,
    # P2.3 (existing 3)
    5, 5, 5,
    # P2.4 (NEW 2)
    5, 5,
    # P3.1 (existing 5 + NEW 2)
    10, 10, 10, 10, 10, 10, 10,
    # P3.2 (existing 2)
    5, 5,
    # P3.2.1 (NEW 2)
    2, 2,
    # P3.3 (existing 4 + NEW 2)
    20, 20, 20, 20, 20, 20,
    # P3.4 (existing 3 + NEW 2)
    10, 10, 10, 10, 10,
    # P3.5 (existing 2 + NEW 2)
    0, 0, 0, 0,
    # P3.6 (existing 2)
    0, 0,
    # P3.7 (NEW 1)
    1,
    # P4 (existing 2)
    50, 50
  ),
  recovery_years_max = c(
    # P1.1
    999, 999, 999, 999, 999,
    # P1.2
    5, 5,
    # P1.3
    100, 100,
    # P1.4
    20, 20,
    # P1.5
    5, 5,
    # P1.6
    35, 35, 35, 35, 35, 35, 35,
    # P2.1
    10, 10, 10,
    # P2.2
    100, 100, 100, 100, 100,
    # P2.3
    30, 30, 30,
    # P2.4
    20, 20,
    # P3.1
    30, 30, 30, 30, 30, 30, 30,
    # P3.2
    15, 15,
    # P3.2.1
    10, 10,
    # P3.3
    100, 100, 100, 100, 100, 100,
    # P3.4
    500, 500, 500, 500, 500,
    # P3.5
    1, 1, 1, 1,
    # P3.6
    1, 1,
    # P3.7
    5,
    # P4
    200, 200
  ),
  reversibility = c(
    # P1.1
    "irreversible", "irreversible", "irreversible", "irreversible", "irreversible",
    # P1.2
    "reversible", "reversible",
    # P1.3
    "partially_reversible", "partially_reversible",
    # P1.4
    "slowly_reversible", "slowly_reversible",
    # P1.5
    "reversible", "reversible",
    # P1.6
    "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible",
    # P2.1
    "reversible", "reversible", "reversible",
    # P2.2
    "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible",
    # P2.3
    "slowly_reversible", "slowly_reversible", "slowly_reversible",
    # P2.4
    "slowly_reversible", "slowly_reversible",
    # P3.1
    "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible", "slowly_reversible",
    # P3.2
    "slowly_reversible", "slowly_reversible",
    # P3.2.1
    "reversible", "reversible",
    # P3.3
    "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible",
    # P3.4
    "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible", "partially_reversible",
    # P3.5
    "reversible", "reversible", "reversible", "reversible",
    # P3.6
    "reversible", "reversible",
    # P3.7
    "reversible",
    # P4
    "partially_reversible", "partially_reversible"
  ),
  stringsAsFactors = FALSE
)

KB_PRESSURE_CONSEQUENCE$confidence_score <- ifelse(
  KB_PRESSURE_CONSEQUENCE$confidence == "HIGH", 0.85,
  ifelse(KB_PRESSURE_CONSEQUENCE$confidence == "MEDIUM", 0.70, 0.50)
)

# =============================================================================
# CONTROL -> PRESSURE CONNECTIONS
# Based on MSFD programmes of measures, HELCOM BSAP, OSPAR measures
# =============================================================================

KB_CONTROL_PRESSURE <- data.frame(
  from_id = c(
    # Ctrl1: Nature protection (existing)
    "Ctrl1.1", "Ctrl1.1", "Ctrl1.1",
    # Ctrl1.2: Nature restoration (NEW parent)
    "Ctrl1.2", "Ctrl1.2",
    "Ctrl1.2.1", "Ctrl1.2.1",
    "Ctrl1.2.2",
    "Ctrl1.2.3",
    # Ctrl1.3: Activities regulation (NEW parent)
    "Ctrl1.3", "Ctrl1.3", "Ctrl1.3",
    "Ctrl1.3.1", "Ctrl1.3.1", "Ctrl1.3.1",
    "Ctrl1.3.2", "Ctrl1.3.2",
    # Ctrl1.3.3: Relocate activities (NEW)
    "Ctrl1.3.3", "Ctrl1.3.3",
    # Ctrl1.3.4: Co-development (NEW)
    "Ctrl1.3.4", "Ctrl1.3.4",
    "Ctrl1.3.5", "Ctrl1.3.5", "Ctrl1.3.5", "Ctrl1.3.5",
    "Ctrl1.3.6", "Ctrl1.3.6",
    "Ctrl1.3.7", "Ctrl1.3.7",
    "Ctrl1.3.8",
    "Ctrl1.3.9", "Ctrl1.3.9",
    # Ctrl2: Innovation (existing)
    "Ctrl2.1",
    "Ctrl2.2", "Ctrl2.2",
    "Ctrl2.2.1", "Ctrl2.2.1",
    "Ctrl2.2.2", "Ctrl2.2.2",
    # Ctrl2.2.3-6: Agricultural practices (NEW)
    "Ctrl2.2.3", "Ctrl2.2.3",
    "Ctrl2.2.4", "Ctrl2.2.4",
    "Ctrl2.2.5", "Ctrl2.2.5",
    "Ctrl2.2.6", "Ctrl2.2.6",
    "Ctrl2.2.8", "Ctrl2.2.9",
    # Ctrl2.2.10: Green energy (NEW)
    "Ctrl2.2.10",
    "Ctrl2.2.11",
    "Ctrl2.2.12", "Ctrl2.2.12",
    # Ctrl2.2.13-14: Flood/erosion defence (NEW)
    "Ctrl2.2.13", "Ctrl2.2.13",
    "Ctrl2.2.14", "Ctrl2.2.14",
    # Ctrl2.3: NID parent (NEW)
    "Ctrl2.3", "Ctrl2.3", "Ctrl2.3",
    "Ctrl2.3.1", "Ctrl2.3.2",
    "Ctrl2.3.3",
    "Ctrl2.3.4", "Ctrl2.3.4",
    "Ctrl2.3.5",
    "Ctrl2.3.6", "Ctrl2.3.7",
    # Ctrl2.3.8: NID specific (NEW)
    "Ctrl2.3.8",
    "Ctrl2.3.9", "Ctrl2.3.10", "Ctrl2.3.11",
    # Ctrl2.3.12-27: NID specific items (NEW)
    "Ctrl2.3.12", "Ctrl2.3.13", "Ctrl2.3.14",
    "Ctrl2.3.15", "Ctrl2.3.16", "Ctrl2.3.17",
    "Ctrl2.3.18", "Ctrl2.3.19",
    "Ctrl2.3.20", "Ctrl2.3.21",
    "Ctrl2.3.22",
    "Ctrl2.3.23", "Ctrl2.3.24", "Ctrl2.3.25",
    "Ctrl2.3.26", "Ctrl2.3.27",
    # Ctrl3: Knowledge (existing)
    "Ctrl3.1", "Ctrl3.1",
    "Ctrl3.2",
    # Ctrl3.3: Disease research (NEW)
    "Ctrl3.3",
    "Ctrl3.4",
    # Ctrl3.5: Knowledge transfer (NEW)
    "Ctrl3.5",
    # Ctrl4: Governance (existing + NEW)
    "Ctrl4.1", "Ctrl4.1",
    "Ctrl4.1.1",
    # Ctrl4.1.2: Specific EU legislation (NEW)
    "Ctrl4.1.2",
    "Ctrl4.1.3",
    # Ctrl4.1.4: Specific EU legislation (NEW)
    "Ctrl4.1.4",
    # Ctrl4.1.5: Specific EU legislation (NEW)
    "Ctrl4.1.5",
    # Ctrl4.2: National legislation (NEW parent)
    "Ctrl4.2", "Ctrl4.2",
    "Ctrl4.2.1", "Ctrl4.2.1",
    # Ctrl4.2.2: Adaptive legislation (NEW)
    "Ctrl4.2.2",
    # Ctrl4.3: Governance tools (NEW parent)
    "Ctrl4.3", "Ctrl4.3",
    # Ctrl4.3.1-6: Specific governance (NEW)
    "Ctrl4.3.1", "Ctrl4.3.2", "Ctrl4.3.3",
    "Ctrl4.3.4", "Ctrl4.3.4",
    "Ctrl4.3.5", "Ctrl4.3.6",
    # Ctrl5: Economic (existing + NEW)
    "Ctrl5.1", "Ctrl5.1",
    # Ctrl5.1.1: Specific funding (NEW)
    "Ctrl5.1.1",
    "Ctrl5.1.2",
    # Ctrl5.1.3-6: Specific funding (NEW)
    "Ctrl5.1.3", "Ctrl5.1.4", "Ctrl5.1.5", "Ctrl5.1.6",
    "Ctrl5.2", "Ctrl5.2",
    # Ctrl5.3: Other economic (NEW)
    "Ctrl5.3",
    # Ctrl6: Cultural/Social (existing + NEW)
    "Ctrl6.1",
    # Ctrl6.2: Social measures (NEW)
    "Ctrl6.2",
    # Ctrl6.3: Social measures (NEW)
    "Ctrl6.3",
    "Ctrl6.4",
    "Ctrl6.5",
    # Ctrl6.6: Social measures (NEW)
    "Ctrl6.6",
    # Ctrl6.7: Social measures (NEW)
    "Ctrl6.7"
  ),
  to_id = c(
    # Ctrl1.1 (existing)
    "P1.5", "P1.6", "P2.1",
    # Ctrl1.2 (NEW parent)
    "P2.2", "P1.6",
    "P2.2", "P2.1",
    "P1.6",
    "P2.2",
    # Ctrl1.3 (NEW parent)
    "P1.6", "P2.1", "P1.5",
    "P1.6", "P1.5", "P2.1",
    "P1.5", "P2.1",
    # Ctrl1.3.3 (NEW)
    "P1.5", "P2.1",
    # Ctrl1.3.4 (NEW)
    "P2.2", "P1.5",
    "P1.6", "P2.1", "P1.5", "P2.2",
    "P1.6", "P2.1",
    "P1.6", "P2.1",
    "P1.5",
    "P3.3", "P3.5",
    # Ctrl2.1 (existing)
    "P3.3",
    # Ctrl2.2 (NEW parent)
    "P3.3", "P3.1",
    "P2.2", "P2.3",
    "P3.3", "P3.1",
    # Ctrl2.2.3-6 (NEW)
    "P3.1", "P3.3",
    "P3.1", "P3.3",
    "P3.1", "P3.3",
    "P3.1", "P3.3",
    "P3.1", "P3.2.1",
    # Ctrl2.2.10 (NEW)
    "P3.3",
    "P3.3",
    "P3.1", "P3.2.1",
    # Ctrl2.2.13-14 (NEW)
    "P2.2", "P2.3",
    "P2.2", "P2.3",
    # Ctrl2.3 (NEW parent)
    "P2.2", "P3.5", "P1.5",
    "P3.5", "P3.5",
    "P3.5",
    "P1.5", "P3.5",
    "P3.5",
    "P1.5", "P1.5",
    # Ctrl2.3.8 (NEW)
    "P2.2",
    "P2.2", "P2.2", "P2.2",
    # Ctrl2.3.12-27 (NEW)
    "P2.2", "P3.5", "P1.5",
    "P2.2", "P3.5", "P1.4",
    "P2.2", "P1.5",
    "P1.4", "P1.4",
    "P1.4",
    "P2.2", "P3.5", "P1.5",
    "P2.2", "P1.5",
    # Ctrl3 (existing)
    "P1.6", "P3.3",
    "P1.6",
    # Ctrl3.3 (NEW)
    "P1.2",
    "P1.2",
    # Ctrl3.5 (NEW)
    "P1.6",
    # Ctrl4.1 (NEW parent)
    "P3.3", "P1.6",
    "P3.3",
    # Ctrl4.1.2 (NEW)
    "P3.1",
    "P1.1",
    # Ctrl4.1.4 (NEW)
    "P1.6",
    # Ctrl4.1.5 (NEW)
    "P3.4",
    # Ctrl4.2 (NEW parent)
    "P3.3", "P1.6",
    "P1.6", "P3.3",
    # Ctrl4.2.2 (NEW)
    "P1.6",
    # Ctrl4.3 (NEW parent)
    "P1.6", "P2.1",
    # Ctrl4.3.1-6 (NEW)
    "P1.6", "P2.1", "P1.5",
    "P1.6", "P2.1",
    "P3.3", "P1.6",
    # Ctrl5.1 (NEW parent)
    "P3.3", "P1.6",
    # Ctrl5.1.1 (NEW)
    "P3.3",
    "P3.3",
    # Ctrl5.1.3-6 (NEW)
    "P2.2", "P3.1", "P1.6", "P3.4",
    "P3.3", "P3.4",
    # Ctrl5.3 (NEW)
    "P3.3",
    # Ctrl6 (existing + NEW)
    "P3.4",
    # Ctrl6.2 (NEW)
    "P3.4",
    # Ctrl6.3 (NEW)
    "P1.6",
    "P1.6",
    "P1.6",
    # Ctrl6.6 (NEW)
    "P3.4",
    # Ctrl6.7 (NEW)
    "P1.6"
  ),
  confidence = c(
    # Ctrl1.1 (existing)
    "HIGH", "HIGH", "HIGH",
    # Ctrl1.2 (NEW parent)
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    "MEDIUM",
    "MEDIUM",
    # Ctrl1.3 (NEW parent)
    "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH",
    # Ctrl1.3.3 (NEW)
    "MEDIUM", "MEDIUM",
    # Ctrl1.3.4 (NEW)
    "MEDIUM", "MEDIUM",
    "HIGH", "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    "MEDIUM",
    "MEDIUM", "MEDIUM",
    # Ctrl2.1 (existing)
    "HIGH",
    # Ctrl2.2 (NEW parent)
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    "HIGH", "HIGH",
    # Ctrl2.2.3-6 (NEW)
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    "MEDIUM", "HIGH",
    # Ctrl2.2.10 (NEW)
    "HIGH",
    "MEDIUM",
    "HIGH", "HIGH",
    # Ctrl2.2.13-14 (NEW)
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    # Ctrl2.3 (NEW parent)
    "MEDIUM", "MEDIUM", "MEDIUM",
    "HIGH", "HIGH",
    "MEDIUM",
    "HIGH", "MEDIUM",
    "HIGH",
    "MEDIUM", "MEDIUM",
    # Ctrl2.3.8 (NEW)
    "MEDIUM",
    "MEDIUM", "MEDIUM", "MEDIUM",
    # Ctrl2.3.12-27 (NEW)
    "MEDIUM", "MEDIUM", "LOW",
    "MEDIUM", "LOW", "LOW",
    "MEDIUM", "LOW",
    "MEDIUM", "MEDIUM",
    "LOW",
    "MEDIUM", "LOW", "LOW",
    "MEDIUM", "LOW",
    # Ctrl3 (existing)
    "MEDIUM", "MEDIUM",
    "MEDIUM",
    # Ctrl3.3 (NEW)
    "MEDIUM",
    "MEDIUM",
    # Ctrl3.5 (NEW)
    "LOW",
    # Ctrl4.1 (NEW parent)
    "HIGH", "HIGH",
    "HIGH",
    # Ctrl4.1.2 (NEW)
    "MEDIUM",
    "HIGH",
    # Ctrl4.1.4 (NEW)
    "MEDIUM",
    # Ctrl4.1.5 (NEW)
    "MEDIUM",
    # Ctrl4.2 (NEW parent)
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    # Ctrl4.2.2 (NEW)
    "MEDIUM",
    # Ctrl4.3 (NEW parent)
    "MEDIUM", "MEDIUM",
    # Ctrl4.3.1-6 (NEW)
    "MEDIUM", "MEDIUM", "MEDIUM",
    "HIGH", "MEDIUM",
    "MEDIUM", "MEDIUM",
    # Ctrl5.1 (NEW parent)
    "MEDIUM", "MEDIUM",
    # Ctrl5.1.1 (NEW)
    "MEDIUM",
    "MEDIUM",
    # Ctrl5.1.3-6 (NEW)
    "MEDIUM", "MEDIUM", "LOW", "LOW",
    "MEDIUM", "MEDIUM",
    # Ctrl5.3 (NEW)
    "LOW",
    # Ctrl6 (existing + NEW)
    "LOW",
    # Ctrl6.2 (NEW)
    "LOW",
    # Ctrl6.3 (NEW)
    "LOW",
    "LOW",
    "LOW",
    # Ctrl6.6 (NEW)
    "LOW",
    # Ctrl6.7 (NEW)
    "LOW"
  ),
  effectiveness = c(
    # Ctrl1.1 (existing)
    "reduces", "reduces", "prevents",
    # Ctrl1.2 (NEW parent)
    "reverses", "reverses",
    "reverses", "reverses",
    "reverses",
    "compensates",
    # Ctrl1.3 (NEW parent)
    "reduces", "reduces", "reduces",
    "reduces", "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl1.3.3 (NEW)
    "reduces", "reduces",
    # Ctrl1.3.4 (NEW)
    "reduces", "reduces",
    "prevents", "prevents", "prevents", "prevents",
    "reduces", "reduces",
    "reduces", "prevents",
    "reduces",
    "reduces", "reduces",
    # Ctrl2.1 (existing)
    "reduces",
    # Ctrl2.2 (NEW parent)
    "reduces", "reduces",
    "prevents", "prevents",
    "reduces", "reduces",
    # Ctrl2.2.3-6 (NEW)
    "reduces", "reduces",
    "reduces", "reduces",
    "reduces", "reduces",
    "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl2.2.10 (NEW)
    "reduces",
    "reduces",
    "reduces", "reduces",
    # Ctrl2.2.13-14 (NEW)
    "prevents", "prevents",
    "prevents", "prevents",
    # Ctrl2.3 (NEW parent)
    "mitigates", "mitigates", "mitigates",
    "mitigates", "mitigates",
    "mitigates",
    "prevents", "mitigates",
    "monitors",
    "monitors", "prevents",
    # Ctrl2.3.8 (NEW)
    "compensates",
    "compensates", "compensates", "compensates",
    # Ctrl2.3.12-27 (NEW)
    "compensates", "mitigates", "reduces",
    "compensates", "mitigates", "reverses",
    "compensates", "reduces",
    "reverses", "reverses",
    "compensates",
    "compensates", "mitigates", "reduces",
    "compensates", "reduces",
    # Ctrl3 (existing)
    "monitors", "monitors",
    "informs",
    # Ctrl3.3 (NEW)
    "monitors",
    "monitors",
    # Ctrl3.5 (NEW)
    "informs",
    # Ctrl4.1 (NEW parent)
    "reduces", "reduces",
    "reduces",
    # Ctrl4.1.2 (NEW)
    "reduces",
    "prevents",
    # Ctrl4.1.4 (NEW)
    "reduces",
    # Ctrl4.1.5 (NEW)
    "reduces",
    # Ctrl4.2 (NEW parent)
    "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl4.2.2 (NEW)
    "reduces",
    # Ctrl4.3 (NEW parent)
    "reduces", "reduces",
    # Ctrl4.3.1-6 (NEW)
    "reduces", "reduces", "reduces",
    "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl5.1 (NEW parent)
    "reduces", "reduces",
    # Ctrl5.1.1 (NEW)
    "reduces",
    "reduces",
    # Ctrl5.1.3-6 (NEW)
    "reduces", "reduces", "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl5.3 (NEW)
    "reduces",
    # Ctrl6 (existing + NEW)
    "reduces",
    # Ctrl6.2 (NEW)
    "reduces",
    # Ctrl6.3 (NEW)
    "reduces",
    "reduces",
    "reduces",
    # Ctrl6.6 (NEW)
    "reduces",
    # Ctrl6.7 (NEW)
    "reduces"
  ),
  msfd_descriptor = c(
    # Ctrl1.1 (existing)
    "D1", "D3", "D6",
    # Ctrl1.2 (NEW parent)
    "D6", "D3",
    "D6", "D6",
    "D3",
    "D6",
    # Ctrl1.3 (NEW parent)
    "D3", "D6", "D1",
    "D3", "D1", "D6",
    "D1", "D6",
    # Ctrl1.3.3 (NEW)
    "D1", "D6",
    # Ctrl1.3.4 (NEW)
    "D6", "D1",
    "D3", "D6", "D1", "D6",
    "D3", "D6",
    "D3", "D6",
    "D1",
    "D8", "D11",
    # Ctrl2.1 (existing)
    "D8",
    # Ctrl2.2 (NEW parent)
    "D8", "D5",
    "D6", "D7",
    "D8", "D5",
    # Ctrl2.2.3-6 (NEW)
    "D5", "D8",
    "D5", "D8",
    "D5", "D8",
    "D5", "D8",
    "D5", "D6",
    # Ctrl2.2.10 (NEW)
    "D8",
    "D8",
    "D5", "D6",
    # Ctrl2.2.13-14 (NEW)
    "D6", "D7",
    "D6", "D7",
    # Ctrl2.3 (NEW parent)
    "D6", "D11", "D1",
    "D11", "D11",
    "D11",
    "D1", "D11",
    "D11",
    "D1", "D1",
    # Ctrl2.3.8 (NEW)
    "D6",
    "D6", "D6", "D6",
    # Ctrl2.3.12-27 (NEW)
    "D6", "D11", "D1",
    "D6", "D11", "D1",
    "D6", "D1",
    "D1", "D1",
    "D1",
    "D6", "D11", "D1",
    "D6", "D1",
    # Ctrl3 (existing)
    "D3", "D8",
    "D3",
    # Ctrl3.3 (NEW)
    "D1",
    "D1",
    # Ctrl3.5 (NEW)
    "D3",
    # Ctrl4.1 (NEW parent)
    "D8", "D3",
    "D8",
    # Ctrl4.1.2 (NEW)
    "D5",
    "D2",
    # Ctrl4.1.4 (NEW)
    "D3",
    # Ctrl4.1.5 (NEW)
    "D10",
    # Ctrl4.2 (NEW parent)
    "D8", "D3",
    "D3", "D8",
    # Ctrl4.2.2 (NEW)
    "D3",
    # Ctrl4.3 (NEW parent)
    "D3", "D6",
    # Ctrl4.3.1-6 (NEW)
    "D3", "D6", "D1",
    "D3", "D6",
    "D8", "D3",
    # Ctrl5.1 (NEW parent)
    "D8", "D3",
    # Ctrl5.1.1 (NEW)
    "D8",
    "D8",
    # Ctrl5.1.3-6 (NEW)
    "D6", "D5", "D3", "D10",
    "D8", "D10",
    # Ctrl5.3 (NEW)
    "D8",
    # Ctrl6 (existing + NEW)
    "D10",
    # Ctrl6.2 (NEW)
    "D10",
    # Ctrl6.3 (NEW)
    "D3",
    "D3",
    "D3",
    # Ctrl6.6 (NEW)
    "D10",
    # Ctrl6.7 (NEW)
    "D3"
  ),
  mechanism = c(
    # Ctrl1.1 (existing)
    "Conservation management reduces human disturbance to wildlife",
    "Conservation management limits overexploitation of species",
    "Conservation management prevents physical habitat damage",
    # Ctrl1.2 (NEW parent)
    "Nature restoration reverses physical habitat loss and degradation",
    "Nature restoration supports recovery of overexploited species",
    # Ctrl1.2.1 (existing)
    "Habitat restoration reverses physical loss and degradation",
    "Ecosystem remediation reverses seabed disturbance impacts",
    # Ctrl1.2.2 (existing)
    "Species restocking reverses overexploitation impacts",
    # Ctrl1.2.3 (existing)
    "Habitat creation compensates for physical habitat loss",
    # Ctrl1.3 (NEW parent)
    "Activity regulation controls species extraction rates",
    "Activity regulation limits physical disturbance to habitats",
    "Activity regulation reduces human disturbance to wildlife",
    # Ctrl1.3.1 (existing)
    "Quotas and catch limits reduce species extraction",
    "Visitor limits reduce disturbance to sensitive species",
    "Activity restrictions prevent physical seabed damage",
    # Ctrl1.3.2 (existing)
    "Spatial planning separates activities from sensitive areas",
    "Zoning prevents physical disturbance in sensitive zones",
    # Ctrl1.3.3 (NEW)
    "Relocating activities away from sensitive areas reduces disturbance",
    "Activity relocation prevents physical disturbance in critical habitats",
    # Ctrl1.3.4 (NEW)
    "Co-development approaches minimize physical habitat loss from construction",
    "Co-development planning reduces disturbance through integrated design",
    # Ctrl1.3.5 (existing)
    "MPAs prevent extraction of species within protected zones",
    "MPAs prevent physical disturbance within boundaries",
    "MPAs eliminate human disturbance in no-access zones",
    "MPAs prevent physical habitat loss within boundaries",
    # Ctrl1.3.6 (existing)
    "No-take zones allow species recovery from extraction",
    "No-activity zones prevent seabed disturbance",
    # Ctrl1.3.7 (existing)
    "Essential habitat protection reduces species extraction pressure",
    "Temporal closures prevent seabed disturbance during recovery",
    # Ctrl1.3.8 (existing)
    "Seasonal restrictions reduce disturbance during critical periods",
    # Ctrl1.3.9 (existing)
    "Mitigation measures reduce contaminant release from activities",
    "Mitigation measures reduce noise emissions from activities",
    # Ctrl2.1 (existing)
    "Reduced fossil fuel use decreases contaminant emissions to sea",
    # Ctrl2.2 (NEW parent)
    "Technology improvements reduce hazardous substance emissions",
    "Technology improvements reduce nutrient discharge to environment",
    # Ctrl2.2.1 (existing)
    "Nature-based solutions avoid permanent seabed habitat loss",
    "Nature-based solutions maintain natural hydrological conditions",
    # Ctrl2.2.2 (existing)
    "Organic farming eliminates synthetic pesticide input to water",
    "Organic farming reduces fertilizer nutrient runoff",
    # Ctrl2.2.3-6 (NEW)
    "Improved crop rotation reduces fertilizer dependency and nutrient runoff",
    "Integrated pest management reduces pesticide contamination of water",
    "Precision agriculture minimizes excess nutrient application",
    "Precision agriculture reduces pesticide use through targeted application",
    "Cover cropping reduces nutrient leaching during fallow periods",
    "Cover cropping reduces need for herbicide application",
    "Conservation tillage reduces nutrient and sediment runoff",
    "Conservation tillage reduces pesticide mobilization in soil",
    # Ctrl2.2.8-9 (existing)
    "Controlled drainage reduces nutrient leaching to water courses",
    "Erosion control reduces sediment input to water courses",
    # Ctrl2.2.10 (NEW)
    "Transition to green energy reduces atmospheric contaminant deposition",
    # Ctrl2.2.11 (existing)
    "Improved treatment reduces contaminant discharge to coast",
    # Ctrl2.2.12 (existing)
    "Riparian buffer zones intercept nutrient runoff from land",
    "Riparian zones trap sediment before reaching water courses",
    # Ctrl2.2.13-14 (NEW)
    "Flood defence infrastructure prevents coastal habitat loss from inundation",
    "Flood defence structures modify hydrological regime to reduce erosion",
    "Erosion defence measures prevent physical loss of coastal habitats",
    "Erosion control structures stabilize hydrological conditions",
    # Ctrl2.3 (NEW parent)
    "Nature-inclusive design compensates for habitat lost to infrastructure",
    "Nature-inclusive design mitigates noise impacts of infrastructure",
    "Nature-inclusive design reduces wildlife disturbance from infrastructure",
    # Ctrl2.3.1-2 (existing)
    "Bubble curtains reduce pile-driving noise by 10-20 dB",
    "Soft-start allows marine mammals to leave before full power",
    # Ctrl2.3.3 (existing)
    "Alternative foundation designs reduce construction noise",
    # Ctrl2.3.4 (existing)
    "Seasonal timing avoids disturbance during breeding/migration",
    "Seasonal restrictions reduce noise during sensitive periods",
    # Ctrl2.3.5 (existing)
    "PAM detects marine mammals to trigger mitigation protocols",
    # Ctrl2.3.6-7 (existing)
    "Radar monitoring enables avoidance of bird/bat collision",
    "Curtailment during migration reduces species disturbance",
    # Ctrl2.3.8 (NEW)
    "Habitat enhancement on infrastructure compensates for lost seabed habitat",
    # Ctrl2.3.9-11 (existing)
    "Artificial reefs compensate for habitat lost to construction",
    "Reef structures create new hard substrate habitat",
    "Modular reefs on scour protection enhance habitat complexity",
    # Ctrl2.3.12-27 (NEW)
    "Fish aggregation devices on structures compensate for habitat loss",
    "Acoustic deterrents reduce noise impact on marine mammals",
    "Wildlife-friendly lighting reduces disturbance to seabirds",
    "Gravity-based foundations minimize seabed disturbance footprint",
    "Vibration dampening systems reduce operational noise",
    "Native species seeding on structures reverses cultivation displacement",
    "Floating platforms minimize seabed contact and habitat loss",
    "Wildlife corridors in infrastructure reduce species disturbance",
    "Oyster reef restoration reverses biogenic habitat loss",
    "Mussel bed enhancement on structures reverses habitat decline",
    "Seaweed cultivation on infrastructure provides habitat function",
    "Biodegradable scour protection compensates for seabed modification",
    "Seasonal turbine management reduces noise during sensitive periods",
    "Decommissioning-in-place provides long-term artificial habitat",
    "Eco-moorings minimize seabed disturbance from anchoring",
    "Community-based monitoring reduces disturbance through awareness",
    # Ctrl3 (existing)
    "Environmental monitoring informs sustainable harvest levels",
    "Contaminant monitoring supports pollution reduction measures",
    "Better assessment methods improve harvest management accuracy",
    # Ctrl3.3 (NEW)
    "Disease research enables early detection and management of pathogen outbreaks",
    # Ctrl3.4 (existing)
    "Early warning systems enable rapid pathogen response",
    # Ctrl3.5 (NEW)
    "Knowledge transfer empowers stakeholders to reduce extraction pressure",
    # Ctrl4.1 (NEW parent)
    "EU legislation mandates reduction of hazardous substance emissions",
    "EU legislation establishes frameworks for sustainable resource use",
    # Ctrl4.1.1 (existing)
    "Climate legislation reduces greenhouse gas and contaminant emissions",
    # Ctrl4.1.2 (NEW)
    "EU water framework directive mandates nutrient reduction targets",
    # Ctrl4.1.3 (existing)
    "Invasive species regulation prevents new introductions",
    # Ctrl4.1.4 (NEW)
    "EU common fisheries policy establishes catch limits and quotas",
    # Ctrl4.1.5 (NEW)
    "EU single-use plastics directive reduces marine litter inputs",
    # Ctrl4.2 (NEW parent)
    "National legislation controls industrial contaminant emissions",
    "National legislation regulates species harvest and extraction",
    # Ctrl4.2.1 (existing)
    "Local legislation controls harvest intensity and methods",
    "Local legislation controls contaminant discharge from activities",
    # Ctrl4.2.2 (NEW)
    "Adaptive legislation adjusts harvest limits based on stock assessments",
    # Ctrl4.3 (NEW parent)
    "Governance tools provide frameworks to manage extraction sustainably",
    "Governance tools coordinate spatial management to reduce disturbance",
    # Ctrl4.3.1-6 (NEW)
    "Marine spatial planning optimizes use and reduces extraction conflicts",
    "Integrated coastal zone management reduces physical disturbance",
    "Environmental impact assessment prevents disturbance of sensitive areas",
    # Ctrl4.3.4 (existing)
    "Ecosystem management plans reduce overall extraction pressure",
    "Ecosystem management plans reduce physical disturbance",
    # Ctrl4.3.5-6 (NEW)
    "Pollution incident response plans reduce contaminant impacts",
    "Compliance monitoring ensures adherence to harvest regulations",
    # Ctrl5.1 (NEW parent)
    "Funding supports development of cleaner technologies",
    "Funding enables species recovery and conservation programmes",
    # Ctrl5.1.1 (NEW)
    "Research funding develops innovative pollution reduction methods",
    # Ctrl5.1.2 (existing)
    "Incentives for low-impact alternatives reduce contaminant release",
    # Ctrl5.1.3-6 (NEW)
    "Habitat restoration funding enables physical recovery of degraded areas",
    "Clean water programme funding reduces agricultural nutrient discharge",
    "Fisheries transition funding supports sustainable harvest practices",
    "Beach cleanup funding reduces litter accumulation in coastal areas",
    # Ctrl5.2 (existing)
    "Pollution taxes create economic incentive to reduce discharges",
    "Litter fees incentivize waste reduction at source",
    # Ctrl5.3 (NEW)
    "Market-based instruments incentivize cleaner production processes",
    # Ctrl6 (existing + NEW)
    "Public awareness reduces littering and waste generation",
    # Ctrl6.2 (NEW)
    "Community engagement in beach cleanups reduces marine litter",
    # Ctrl6.3 (NEW)
    "Citizen science monitoring supports sustainable resource management",
    # Ctrl6.4 (existing)
    "Consumer education enables sustainable seafood choices",
    # Ctrl6.5 (existing)
    "Promoting alternative species reduces pressure on depleted stocks",
    # Ctrl6.6 (NEW)
    "Environmental education in schools reduces future littering behaviour",
    # Ctrl6.7 (NEW)
    "Stakeholder engagement in fisheries management reduces overexploitation"
  ),
  citation = c(
    # Ctrl1.1 (existing)
    rep("ospar_qsr_2023", 3),
    # Ctrl1.2 (NEW parent)
    "borgwardt_2019", "borgwardt_2019",
    rep("borgwardt_2019", 2),
    "eu_cfs",
    "borgwardt_2019",
    # Ctrl1.3 (NEW parent)
    "knights_2015", "knights_2015", "knights_2015",
    "eu_cfs", rep("borgwardt_2019", 2),
    rep("knights_2015", 2),
    # Ctrl1.3.3 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    # Ctrl1.3.4 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    rep("ospar_qsr_2023", 4),
    rep("helcom_holas3", 2),
    rep("ospar_qsr_2023", 2),
    "borgwardt_2019",
    rep("knights_2015", 2),
    # Ctrl2.1 (existing)
    "korpinen_2021",
    # Ctrl2.2 (NEW parent)
    "korpinen_2021", "korpinen_2021",
    rep("borgwardt_2019", 2),
    rep("eu_nitrates", 2),
    # Ctrl2.2.3-6 (NEW)
    "eu_nitrates", "eu_nitrates",
    "eu_nitrates", "eu_nitrates",
    "eu_nitrates", "eu_nitrates",
    "eu_nitrates", "eu_nitrates",
    "korpinen_2021", "korpinen_2021",
    # Ctrl2.2.10 (NEW)
    "korpinen_2021",
    "eu_uwwtd",
    rep("korpinen_2021", 2),
    # Ctrl2.2.13-14 (NEW)
    "borgwardt_2019", "borgwardt_2019",
    "borgwardt_2019", "borgwardt_2019",
    # Ctrl2.3 (NEW parent)
    "borgwardt_2019", "borgwardt_2019", "borgwardt_2019",
    rep("borgwardt_2019", 2),
    "borgwardt_2019",
    rep("borgwardt_2019", 2),
    "borgwardt_2019",
    rep("borgwardt_2019", 2),
    # Ctrl2.3.8 (NEW)
    "borgwardt_2019",
    rep("borgwardt_2019", 3),
    # Ctrl2.3.12-27 (NEW)
    rep("borgwardt_2019", 16),
    # Ctrl3 (existing)
    rep("helcom_holas3", 2),
    "knights_2015",
    # Ctrl3.3 (NEW)
    "msfd_2017_848",
    "msfd_2017_848",
    # Ctrl3.5 (NEW)
    "borgwardt_2019",
    # Ctrl4.1 (NEW parent)
    "msfd_2017_848", "msfd_2017_848",
    "msfd_2017_848",
    # Ctrl4.1.2 (NEW)
    "eu_uwwtd",
    "imo_bwm",
    # Ctrl4.1.4 (NEW)
    "eu_cfs",
    # Ctrl4.1.5 (NEW)
    "ospar_qsr_2023",
    # Ctrl4.2 (NEW parent)
    "ospar_qsr_2023", "ospar_qsr_2023",
    rep("ospar_qsr_2023", 2),
    # Ctrl4.2.2 (NEW)
    "ospar_qsr_2023",
    # Ctrl4.3 (NEW parent)
    "helcom_holas3", "helcom_holas3",
    # Ctrl4.3.1-6 (NEW)
    "helcom_holas3", "helcom_holas3", "helcom_holas3",
    rep("helcom_holas3", 2),
    "helcom_holas3", "helcom_holas3",
    # Ctrl5.1 (NEW parent)
    "knights_2015", "knights_2015",
    # Ctrl5.1.1 (NEW)
    "knights_2015",
    "knights_2015",
    # Ctrl5.1.3-6 (NEW)
    "borgwardt_2019", "borgwardt_2019", "eu_cfs", "ospar_qsr_2023",
    rep("ospar_qsr_2023", 2),
    # Ctrl5.3 (NEW)
    "knights_2015",
    # Ctrl6 (existing + NEW)
    "borgwardt_2019",
    # Ctrl6.2 (NEW)
    "borgwardt_2019",
    # Ctrl6.3 (NEW)
    "borgwardt_2019",
    "borgwardt_2019",
    "borgwardt_2019",
    # Ctrl6.6 (NEW)
    "borgwardt_2019",
    # Ctrl6.7 (NEW)
    "borgwardt_2019"
  ),
  stringsAsFactors = FALSE
)

KB_CONTROL_PRESSURE$confidence_score <- ifelse(
  KB_CONTROL_PRESSURE$confidence == "HIGH", 0.85,
  ifelse(KB_CONTROL_PRESSURE$confidence == "MEDIUM", 0.70, 0.50)
)

# =============================================================================
# ASSEMBLED KNOWLEDGE BASE
# =============================================================================

CAUSAL_KB <- list(
  activity_pressure = KB_ACTIVITY_PRESSURE,
  pressure_consequence = KB_PRESSURE_CONSEQUENCE,
  control_pressure = KB_CONTROL_PRESSURE,
  references = KB_REFERENCES
)

# =============================================================================
# LOOKUP FUNCTIONS
# =============================================================================

#' Look up causal connections from the knowledge base
#'
#' @param from_ids Character vector of source item IDs
#' @param from_type One of "Activity", "Pressure", "Control"
#' @param to_type One of "Pressure", "Consequence"
#' @return Data frame of matching connections with columns:
#'   from_id, to_id, confidence, confidence_score, msfd_descriptor, mechanism, citation
find_kb_connections <- function(from_ids, from_type, to_type) {
  if (is.null(from_ids) || length(from_ids) == 0) {
    return(data.frame(
      from_id = character(), to_id = character(),
      confidence = character(), confidence_score = numeric(),
      msfd_descriptor = character(), mechanism = character(),
      citation = character(), stringsAsFactors = FALSE
    ))
  }

  # Select the appropriate table
  if (from_type == "Activity" && to_type == "Pressure") {
    kb_table <- CAUSAL_KB$activity_pressure
  } else if (from_type == "Pressure" && to_type == "Consequence") {
    kb_table <- CAUSAL_KB$pressure_consequence
  } else if (from_type == "Control" && to_type == "Pressure") {
    kb_table <- CAUSAL_KB$control_pressure
  } else {
    return(data.frame(
      from_id = character(), to_id = character(),
      confidence = character(), confidence_score = numeric(),
      msfd_descriptor = character(), mechanism = character(),
      citation = character(), stringsAsFactors = FALSE
    ))
  }

  # Filter by from_ids
  matches <- kb_table[kb_table$from_id %in% from_ids, ]
  return(matches)
}

#' Get all connections for a specific item (in either direction)
#'
#' @param item_id Character, the vocabulary item ID
#' @return List with upstream and downstream connections
get_kb_item_connections <- function(item_id) {
  list(
    causes = CAUSAL_KB$activity_pressure[CAUSAL_KB$activity_pressure$to_id == item_id, ],
    effects = rbind(
      CAUSAL_KB$activity_pressure[CAUSAL_KB$activity_pressure$from_id == item_id, ],
      CAUSAL_KB$pressure_consequence[CAUSAL_KB$pressure_consequence$from_id == item_id, ]
    ),
    controls = CAUSAL_KB$control_pressure[CAUSAL_KB$control_pressure$to_id == item_id, ],
    controlled_by = CAUSAL_KB$control_pressure[CAUSAL_KB$control_pressure$from_id == item_id, ]
  )
}

#' Get formatted reference list for citations used in a set of connections
#'
#' @param citation_keys Character vector of citation keys
#' @return Data frame with full reference details and URLs
get_kb_references <- function(citation_keys = NULL) {
  refs <- CAUSAL_KB$references
  if (!is.null(citation_keys)) {
    refs <- refs[refs$key %in% unique(citation_keys), ]
  }
  # Format APA-style citation string
  refs$formatted <- paste0(
    refs$authors, " (", refs$year, "). ",
    refs$title, ". ",
    refs$journal, ".",
    ifelse(nzchar(refs$doi), paste0(" DOI: ", refs$doi), "")
  )
  refs
}

#' Get recovery time information for a pressure
#'
#' @param pressure_id Character, the pressure ID (e.g., "P1.1", "P3.3")
#' @return List with pressure_id, recovery_years_min, recovery_years_max, reversibility
#'   or NULL if no data found
get_kb_recovery_info <- function(pressure_id) {
  pc <- CAUSAL_KB$pressure_consequence
  rows <- pc[pc$from_id == pressure_id, ]
  if (nrow(rows) == 0) return(NULL)
  list(
    pressure_id = pressure_id,
    recovery_years_min = rows$recovery_years_min[1],
    recovery_years_max = rows$recovery_years_max[1],
    reversibility = rows$reversibility[1]
  )
}

#' Calculate ODEMM risk score for an activity-pressure pair
#'
#' Based on Knights et al. (2015) 5-criteria framework.
#' Returns a composite risk score from spatial_extent, frequency, persistence, severity.
#'
#' @param activity_id Character, the activity ID (e.g., "A4.1")
#' @param pressure_id Character, the pressure ID (e.g., "P1.6")
#' @return List with component scores, composite risk_score, and risk_level
#'   or NULL if no data found
calculate_odemm_risk <- function(activity_id, pressure_id) {
  ap <- CAUSAL_KB$activity_pressure
  row <- ap[ap$from_id == activity_id & ap$to_id == pressure_id, ]
  if (nrow(row) == 0) return(NULL)
  risk_score <- (row$spatial_extent[1] + row$frequency[1] + row$persistence[1] + row$severity[1]) / 4
  list(
    activity_id = activity_id,
    pressure_id = pressure_id,
    spatial_extent = row$spatial_extent[1],
    frequency = row$frequency[1],
    persistence = row$persistence[1],
    severity = row$severity[1],
    risk_score = risk_score,
    risk_level = if (risk_score >= 4) "very_high" else if (risk_score >= 3) "high" else if (risk_score >= 2) "medium" else "low"
  )
}

#' Get knowledge base statistics
#'
#' @return Named list with counts and coverage info
get_kb_stats <- function() {
  ap <- CAUSAL_KB$activity_pressure
  pc <- CAUSAL_KB$pressure_consequence
  cp <- CAUSAL_KB$control_pressure

  list(
    total_connections = nrow(ap) + nrow(pc) + nrow(cp),
    activity_pressure_links = nrow(ap),
    pressure_consequence_links = nrow(pc),
    control_pressure_links = nrow(cp),
    unique_activities = length(unique(ap$from_id)),
    unique_pressures = length(unique(c(
      ap$to_id,
      pc$from_id,
      cp$to_id
    ))),
    unique_consequences = length(unique(pc$to_id)),
    unique_controls = length(unique(cp$from_id)),
    references_count = nrow(CAUSAL_KB$references),
    high_confidence_pct = round(100 * mean(c(
      ap$confidence == "HIGH",
      pc$confidence == "HIGH",
      cp$confidence == "HIGH"
    )), 1),
    has_odemm_scores = all(c("spatial_extent", "frequency", "persistence", "severity") %in% names(ap)),
    has_recovery_info = all(c("recovery_years_min", "recovery_years_max", "reversibility") %in% names(pc)),
    reversibility_categories = if ("reversibility" %in% names(pc)) table(pc$reversibility) else NULL,
    mean_odemm_risk = if ("spatial_extent" %in% names(ap)) {
      round(mean((ap$spatial_extent + ap$frequency + ap$persistence + ap$severity) / 4), 2)
    } else {
      NA
    }
  )
}

log_info("Causal knowledge base v2.0.0 loaded successfully")
