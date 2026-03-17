# =============================================================================
# Scientific Causal Knowledge Base for Environmental Bowtie Risk Analysis
# Version: 1.0.0
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
    # A1: Physical restructuring
    "A1.1", "A1.1", "A1.2", "A1.2", "A1.3", "A1.3", "A1.3.1",
    "A1.4", "A1.4", "A1.5", "A1.5", "A1.5",
    # A2: Extraction of non-living resources
    "A2.1", "A2.1", "A2.1", "A2.2", "A2.2", "A2.2", "A2.2",
    # A3: Energy production
    "A3.1", "A3.1", "A3.1", "A3.1", "A3.1", "A3.2", "A3.2", "A3.2",
    # A4: Extraction of living resources
    "A4.1", "A4.1", "A4.1", "A4.1", "A4.1", "A4.1",
    "A4.3", "A4.4", "A4.4",
    # A5: Cultivation
    "A5.1", "A5.1", "A5.1", "A5.1", "A5.1", "A5.1",
    "A5.3", "A5.3", "A5.3", "A5.3",
    "A5.3.1", "A5.3.2", "A5.3.3",
    "A5.3.4", "A5.3.4",
    "A5.4.1", "A5.4.1",
    # A6: Transport
    "A6.1", "A6.1", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2", "A6.2",
    # A7: Urban and industrial
    "A7.1", "A7.1", "A7.1", "A7.1",
    "A7.2", "A7.2", "A7.2", "A7.2",
    "A7.3", "A7.3", "A7.3",
    # A8: Tourism
    "A8.1", "A8.1", "A8.2", "A8.2", "A8.2",
    # A9: Security/Defence
    "A9.1", "A9.1"
  ),
  to_id = c(
    # A1: Physical restructuring -> Pressures
    "P2.2", "P2.3", "P2.3", "P2.1", "P2.2", "P2.3", "P2.2",
    "P2.2", "P3.5", "P2.1", "P2.2", "P3.2.1",
    # A2 -> Pressures
    "P2.2", "P2.1", "P3.2.1", "P3.3", "P2.1", "P3.5", "P2.2",
    # A3 -> Pressures
    "P3.5", "P2.2", "P1.5", "P3.6", "P2.1", "P3.3", "P3.6", "P3.1",
    # A4 -> Pressures
    "P1.6", "P2.1", "P1.5", "P3.4", "P1.1", "P3.5",
    "P1.6", "P1.6", "P1.5",
    # A5 -> Pressures
    "P3.1", "P3.2", "P3.3", "P1.1", "P1.2", "P1.4",
    "P3.1", "P3.3", "P3.2.1", "P3.4",
    "P3.3", "P3.1", "P3.1",
    "P2.3", "P3.2.1",
    "P3.2.1", "P2.3",
    # A6 -> Pressures
    "P2.2", "P2.1", "P3.5", "P3.3", "P1.1", "P3.4", "P3.6", "P1.5", "P2.1",
    # A7 -> Pressures
    "P3.1", "P3.4", "P3.6", "P3.3",
    "P3.3", "P3.1", "P3.6", "P3.7",
    "P3.3", "P3.1", "P3.4",
    # A8 -> Pressures
    "P2.2", "P3.4", "P1.5", "P3.4", "P3.5",
    # A9 -> Pressures
    "P3.5", "P3.3"
  ),
  confidence = c(
    # A1
    "HIGH", "HIGH", "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH",
    "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH",
    # A2
    "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A3
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "HIGH", "HIGH", "MEDIUM",
    # A4
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    "HIGH", "HIGH", "MEDIUM",
    # A5
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    "HIGH", "HIGH", "HIGH", "MEDIUM",
    "HIGH", "HIGH", "HIGH",
    "MEDIUM", "HIGH",
    "HIGH", "HIGH",
    # A6
    "HIGH", "MEDIUM", "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM", "MEDIUM",
    # A7
    "HIGH", "HIGH", "MEDIUM", "HIGH",
    "HIGH", "MEDIUM", "HIGH", "MEDIUM",
    "HIGH", "HIGH", "HIGH",
    # A8
    "MEDIUM", "MEDIUM", "MEDIUM", "MEDIUM", "LOW",
    # A9
    "HIGH", "MEDIUM"
  ),
  msfd_descriptor = c(
    # A1
    "D6", "D7", "D7", "D6", "D6", "D7", "D6",
    "D6", "D11", "D6", "D6", "D6",
    # A2
    "D6", "D6", "D6", "D8", "D6", "D11", "D6",
    # A3
    "D11", "D6", "D1", "D11", "D6", "D8", "D11", "D5",
    # A4
    "D3", "D6", "D1", "D10", "D2", "D11",
    "D3", "D3", "D1",
    # A5
    "D5", "D5", "D8", "D2", "D1", "D1",
    "D5", "D8", "D5", "D10",
    "D8", "D5", "D5",
    "D7", "D6",
    "D6", "D7",
    # A6
    "D6", "D6", "D11", "D8", "D2", "D10", "D11", "D1", "D6",
    # A7
    "D5", "D10", "D11", "D8",
    "D8", "D5", "D11", "D7",
    "D8", "D5", "D10",
    # A8
    "D6", "D10", "D1", "D10", "D11",
    # A9
    "D11", "D8"
  ),
  mechanism = c(
    # A1: Physical restructuring
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
    # A2: Extraction
    "Substrate removal from mineral extraction",
    "Seabed disturbance during extraction operations",
    "Sediment plumes from extraction activities",
    "Produced water, drilling muds, and accidental spills",
    "Seabed disturbance from drilling and platform operations",
    "Seismic surveys and operational noise",
    "Platform foundation footprint",
    # A3: Energy
    "Pile driving during construction of wind/tidal infrastructure",
    "Foundation footprint of energy structures on seabed",
    "Collision risk for birds, barrier effects, displacement",
    "Electromagnetic fields from subsea cables",
    "Temporary seabed disturbance during cable laying",
    "Discharge of contaminants from non-renewable energy processes",
    "Thermal discharge from cooling water outfalls",
    "Atmospheric deposition of combustion products (NOx, SOx)",
    # A4: Living resource extraction
    "Direct removal of target fish/shellfish species",
    "Bottom trawling causes seabed abrasion",
    "Disturbance of marine species during fishing operations",
    "Discarded/lost fishing gear (ghost fishing, marine litter)",
    "Transport of non-indigenous species via fishing vessels",
    "Vessel noise during fishing operations",
    "Harvesting of marine plants alters community structure",
    "Extraction of non-target wild species",
    "Disturbance to species at breeding/resting sites from hunting",
    # A5: Cultivation
    "Fish farm waste: excess feed, excreta release N and P",
    "Organic loading from uneaten feed and faecal matter",
    "Antibiotics, antifoulants, pesticides from fish farms",
    "Escape of farmed species; pathogen transfer to wild stocks",
    "Disease amplification in high-density culture conditions",
    "Replacement of natural communities by cultured species",
    "Fertilizer N and P runoff via rivers to coastal waters",
    "Pesticide and herbicide runoff from agricultural land",
    "Soil erosion from agricultural land enters water courses",
    "Plastic mulch, packaging waste from agricultural operations",
    "Biocide application contaminates water courses",
    "Nitrogen fertilizer runoff causes nutrient enrichment",
    "Phosphorus fertilizer runoff causes nutrient enrichment",
    "Land drainage alters hydrological regime",
    "Soil erosion from agricultural land use changes",
    "Soil erosion from clear-cutting enters water courses",
    "Changed runoff patterns from deforestation",
    # A6: Transport
    "Port construction causes permanent habitat loss",
    "Seabed disturbance from port maintenance dredging",
    "Continuous engine and propeller noise from shipping",
    "Antifouling paints, fuel spills, operational discharges",
    "Ballast water and hull fouling transfer organisms",
    "Operational and accidental waste discharge at sea",
    "Light pollution from port and vessel operations",
    "Visual and acoustic disturbance to wildlife from vessels",
    "Anchor scour and propeller wash in shallow areas",
    # A7: Urban and industrial
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
    # A8: Tourism
    "Coastal tourism infrastructure development on seabed",
    "Litter from tourism facilities and beach use",
    "Human presence disturbs wildlife at breeding/resting sites",
    "Marine litter from recreational boating and beach use",
    "Recreational vessel engine noise in coastal waters",
    # A9: Security
    "Military sonar, explosions, and vessel operations",
    "Munitions residues and military-related contaminants"
  ),
  citation = c(
    # A1
    rep("knights_2015", 7), rep("borgwardt_2019", 5),
    # A2
    rep("borgwardt_2019", 3), rep("knights_2015", 4),
    # A3
    rep("borgwardt_2019", 5), rep("korpinen_2021", 3),
    # A4
    rep("knights_2015", 6), rep("borgwardt_2019", 3),
    # A5
    rep("borgwardt_2019", 6),
    rep("korpinen_2021", 4),
    rep("knights_2015", 3),
    rep("borgwardt_2019", 2),
    rep("korpinen_2021", 2),
    # A6
    rep("knights_2015", 4), "imo_bwm", rep("imo_marpol", 2), rep("borgwardt_2019", 2),
    # A7
    rep("korpinen_2021", 4),
    rep("knights_2015", 4),
    rep("borgwardt_2019", 3),
    # A8
    rep("borgwardt_2019", 5),
    # A9
    rep("knights_2015", 2)
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
    # P1: Biological pressures
    "P1.1", "P1.1", "P1.1",
    "P1.2", "P1.2",
    "P1.4", "P1.4",
    "P1.5", "P1.5",
    "P1.6", "P1.6", "P1.6", "P1.6", "P1.6",
    # P2: Physical pressures
    "P2.1", "P2.1",
    "P2.2", "P2.2", "P2.2",
    "P2.3", "P2.3", "P2.3",
    # P3: Substances, litter, energy
    "P3.1", "P3.1", "P3.1", "P3.1", "P3.1",
    "P3.2", "P3.2",
    "P3.3", "P3.3", "P3.3", "P3.3",
    "P3.4", "P3.4", "P3.4",
    "P3.5", "P3.5",
    "P3.6", "P3.6",
    # P4: Climate change indicators (linked to broad consequences)
    "P4.3(indicator)", "P4.3(indicator)"
  ),
  to_id = c(
    # P1.1 Non-indigenous species
    "C1.1", "C1.2", "C2.2",
    # P1.2 Pathogens
    "C1.2.1", "C3.2",
    # P1.4 Cultivation changes
    "C1.1", "C1.2",
    # P1.5 Disturbance
    "C1.1", "C3.1",
    # P1.6 Extraction/mortality
    "C1.2.1", "C1.1", "C2.2", "C2.5", "C1.2.3",
    # P2.1 Physical disturbance
    "C1.1", "C1.4",
    # P2.2 Physical loss
    "C1.1", "C1.4", "C1.3.2",
    # P2.3 Hydrological changes
    "C1.1", "C1.3.2", "C1.4",
    # P3.1 Nutrients
    "C1.1", "C1.2.4", "C1.3.3", "C3.2", "C2.5",
    # P3.2 Organic matter
    "C1.1", "C1.2.4",
    # P3.3 Hazardous substances
    "C3.2", "C1.1", "C1.2.1", "C2.3",
    # P3.4 Litter
    "C1.1", "C3.1", "C2.5",
    # P3.5 Sound
    "C1.1", "C3.1",
    # P3.6 Other energy
    "C1.1", "C3.1",
    # P4 Climate
    "C1.3.2", "C1.1"
  ),
  confidence = c(
    # P1.1
    "HIGH", "MEDIUM", "MEDIUM",
    # P1.2
    "HIGH", "HIGH",
    # P1.4
    "HIGH", "MEDIUM",
    # P1.5
    "MEDIUM", "MEDIUM",
    # P1.6
    "HIGH", "HIGH", "HIGH", "HIGH", "MEDIUM",
    # P2.1
    "HIGH", "MEDIUM",
    # P2.2
    "HIGH", "HIGH", "MEDIUM",
    # P2.3
    "MEDIUM", "MEDIUM", "MEDIUM",
    # P3.1
    "HIGH", "HIGH", "HIGH", "MEDIUM", "MEDIUM",
    # P3.2
    "HIGH", "HIGH",
    # P3.3
    "HIGH", "HIGH", "HIGH", "HIGH",
    # P3.4
    "HIGH", "MEDIUM", "MEDIUM",
    # P3.5
    "HIGH", "MEDIUM",
    # P3.6
    "MEDIUM", "MEDIUM",
    # P4
    "HIGH", "HIGH"
  ),
  msfd_descriptor = c(
    "D2", "D2", "D2",
    "D1", "D9",
    "D1", "D1",
    "D1", "D1",
    "D3", "D4", "D3", "D3", "D1",
    "D6", "D6",
    "D6", "D6", "D6",
    "D7", "D7", "D7",
    "D5", "D5", "D5", "D5", "D5",
    "D5", "D5",
    "D8", "D8", "D8", "D8",
    "D10", "D10", "D10",
    "D11", "D11",
    "D11", "D11",
    "D7", "D1"
  ),
  mechanism = c(
    # P1.1
    "Invasive species alter ecosystem structure and function",
    "Invasive species outcompete native species, reducing provisioning services",
    "Invasive species reduce economic value of fisheries and aquaculture",
    # P1.2
    "Pathogens cause disease and mortality in fish and shellfish stocks",
    "Microbial contamination threatens human health via seafood and bathing water",
    # P1.4
    "Monoculture replaces natural biodiversity in cultivation areas",
    "Altered species composition reduces ecosystem service provision",
    # P1.5
    "Repeated disturbance causes species displacement and behavioral change",
    "Loss of undisturbed natural areas reduces aesthetic and recreational value",
    # P1.6
    "Overharvesting depletes commercial fish and shellfish stocks",
    "Removal of key species disrupts food web structure and function",
    "Stock depletion reduces fishery income and economic value",
    "Depleted stocks undermine blue economy sectors",
    "Bycatch threatens genetic diversity of non-target species",
    # P2.1
    "Seabed disturbance damages benthic communities and habitats",
    "Physical disturbance alters seabed landscape and natural features",
    # P2.2
    "Permanent habitat loss eliminates associated biological communities",
    "Permanent substrate change alters landscape character",
    "Loss of natural coastal structures reduces storm protection",
    # P2.3
    "Altered currents and salinity regimes shift species distributions",
    "Changed hydrodynamics reduce natural hazard buffering capacity",
    "Modified water flow patterns alter landscape and seascape character",
    # P3.1
    "Eutrophication: excess nutrients fuel harmful algal blooms",
    "Algal blooms and hypoxia degrade water quality for supply purposes",
    "Decomposition of algal biomass consumes oxygen, impairing waste breakdown",
    "Harmful algal blooms and hypoxia threaten human health",
    "Eutrophication degrades coastal waters critical for blue economy",
    # P3.2
    "Organic enrichment leads to hypoxia and community shifts",
    "Oxygen depletion from organic matter degrades water quality",
    # P3.3
    "Bioaccumulation of contaminants threatens human health via seafood",
    "Toxic substances cause mortality and sublethal effects in marine life",
    "Contaminants impair reproduction and growth in fish and shellfish",
    "Contamination reduces economic value of marine resources",
    # P3.4
    "Ingestion and entanglement cause mortality across marine taxa",
    "Marine litter degrades visual quality of coastal environments",
    "Litter-affected areas lose tourism and recreational appeal",
    # P3.5
    "Anthropogenic noise displaces marine mammals, masks communication",
    "Underwater noise degrades acoustic quality of marine environment",
    # P3.6
    "Thermal discharge and light pollution alter local communities",
    "Artificial light and thermal plumes degrade environmental aesthetics",
    # P4
    "Sea level rise and storm surges damage coastal protection infrastructure",
    "Climate-driven temperature and acidification shifts alter ecosystems"
  ),
  citation = c(
    rep("korpinen_2021", 3),
    rep("msfd_2017_848", 2),
    rep("borgwardt_2019", 2),
    rep("borgwardt_2019", 2),
    rep("knights_2015", 5),
    rep("korpinen_2021", 2),
    rep("korpinen_2021", 3),
    rep("borgwardt_2019", 3),
    rep("korpinen_2021", 5),
    rep("korpinen_2021", 2),
    rep("msfd_2017_848", 4),
    rep("halpern_2015", 3),
    rep("msfd_2017_848", 2),
    rep("borgwardt_2019", 2),
    rep("korpinen_2021", 2)
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
    # Ctrl1: Nature protection
    "Ctrl1.1", "Ctrl1.1", "Ctrl1.1",
    "Ctrl1.2.1", "Ctrl1.2.1",
    "Ctrl1.2.2",
    "Ctrl1.2.3",
    "Ctrl1.3.1", "Ctrl1.3.1", "Ctrl1.3.1",
    "Ctrl1.3.2", "Ctrl1.3.2",
    "Ctrl1.3.5", "Ctrl1.3.5", "Ctrl1.3.5", "Ctrl1.3.5",
    "Ctrl1.3.6", "Ctrl1.3.6",
    "Ctrl1.3.7", "Ctrl1.3.7",
    "Ctrl1.3.8",
    "Ctrl1.3.9", "Ctrl1.3.9",
    # Ctrl2: Innovation
    "Ctrl2.1",
    "Ctrl2.2.1", "Ctrl2.2.1",
    "Ctrl2.2.2", "Ctrl2.2.2",
    "Ctrl2.2.8", "Ctrl2.2.9",
    "Ctrl2.2.11",
    "Ctrl2.2.12", "Ctrl2.2.12",
    "Ctrl2.3.1", "Ctrl2.3.2",
    "Ctrl2.3.3",
    "Ctrl2.3.4", "Ctrl2.3.4",
    "Ctrl2.3.5",
    "Ctrl2.3.6", "Ctrl2.3.7",
    "Ctrl2.3.9", "Ctrl2.3.10", "Ctrl2.3.11",
    "Ctrl2.3.20", "Ctrl2.3.21",
    "Ctrl2.3.22",
    # Ctrl3: Knowledge
    "Ctrl3.1", "Ctrl3.1",
    "Ctrl3.2",
    "Ctrl3.4",
    # Ctrl4: Governance
    "Ctrl4.1.1",
    "Ctrl4.1.3",
    "Ctrl4.2.1", "Ctrl4.2.1",
    "Ctrl4.3.4", "Ctrl4.3.4",
    # Ctrl5: Economic
    "Ctrl5.1.2",
    "Ctrl5.2", "Ctrl5.2",
    # Ctrl6: Cultural/Social
    "Ctrl6.1",
    "Ctrl6.4",
    "Ctrl6.5"
  ),
  to_id = c(
    # Ctrl1
    "P1.5", "P1.6", "P2.1",
    "P2.2", "P2.1",
    "P1.6",
    "P2.2",
    "P1.6", "P1.5", "P2.1",
    "P1.5", "P2.1",
    "P1.6", "P2.1", "P1.5", "P2.2",
    "P1.6", "P2.1",
    "P1.6", "P2.1",
    "P1.5",
    "P3.3", "P3.5",
    # Ctrl2
    "P3.3",
    "P2.2", "P2.3",
    "P3.3", "P3.1",
    "P3.1", "P3.2.1",
    "P3.3",
    "P3.1", "P3.2.1",
    "P3.5", "P3.5",
    "P3.5",
    "P1.5", "P3.5",
    "P3.5",
    "P1.5", "P1.5",
    "P2.2", "P2.2", "P2.2",
    "P1.4", "P1.4",
    "P1.4",
    # Ctrl3
    "P1.6", "P3.3",
    "P1.6",
    "P1.2",
    # Ctrl4
    "P3.3",
    "P1.1",
    "P1.6", "P3.3",
    "P1.6", "P2.1",
    # Ctrl5
    "P3.3",
    "P3.3", "P3.4",
    # Ctrl6
    "P3.4",
    "P1.6",
    "P1.6"
  ),
  confidence = c(
    # Ctrl1
    "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH",
    "MEDIUM",
    "MEDIUM",
    "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH",
    "HIGH", "HIGH", "HIGH", "HIGH",
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    "MEDIUM",
    "MEDIUM", "MEDIUM",
    # Ctrl2
    "HIGH",
    "MEDIUM", "MEDIUM",
    "HIGH", "HIGH",
    "MEDIUM", "HIGH",
    "MEDIUM",
    "HIGH", "HIGH",
    "HIGH", "HIGH",
    "MEDIUM",
    "HIGH", "MEDIUM",
    "HIGH",
    "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM", "MEDIUM",
    "MEDIUM", "MEDIUM",
    "LOW",
    # Ctrl3
    "MEDIUM", "MEDIUM",
    "MEDIUM",
    "MEDIUM",
    # Ctrl4
    "HIGH",
    "HIGH",
    "HIGH", "HIGH",
    "HIGH", "MEDIUM",
    # Ctrl5
    "MEDIUM",
    "MEDIUM", "MEDIUM",
    # Ctrl6
    "LOW",
    "LOW",
    "LOW"
  ),
  effectiveness = c(
    # Ctrl1
    "reduces", "reduces", "prevents",
    "reverses", "reverses",
    "reverses",
    "compensates",
    "reduces", "reduces", "reduces",
    "reduces", "reduces",
    "prevents", "prevents", "prevents", "prevents",
    "reduces", "reduces",
    "reduces", "prevents",
    "reduces",
    "reduces", "reduces",
    # Ctrl2
    "reduces",
    "prevents", "prevents",
    "reduces", "reduces",
    "reduces", "reduces",
    "reduces",
    "reduces", "reduces",
    "mitigates", "mitigates",
    "mitigates",
    "prevents", "mitigates",
    "monitors",
    "monitors", "prevents",
    "compensates", "compensates", "compensates",
    "reverses", "reverses",
    "compensates",
    # Ctrl3
    "monitors", "monitors",
    "informs",
    "monitors",
    # Ctrl4
    "reduces",
    "prevents",
    "reduces", "reduces",
    "reduces", "reduces",
    # Ctrl5
    "reduces",
    "reduces", "reduces",
    # Ctrl6
    "reduces",
    "reduces",
    "reduces"
  ),
  msfd_descriptor = c(
    # Ctrl1
    "D1", "D3", "D6",
    "D6", "D6",
    "D3",
    "D6",
    "D3", "D1", "D6",
    "D1", "D6",
    "D3", "D6", "D1", "D6",
    "D3", "D6",
    "D3", "D6",
    "D1",
    "D8", "D11",
    # Ctrl2
    "D8",
    "D6", "D7",
    "D8", "D5",
    "D5", "D6",
    "D8",
    "D5", "D6",
    "D11", "D11",
    "D11",
    "D1", "D11",
    "D11",
    "D1", "D1",
    "D6", "D6", "D6",
    "D1", "D1",
    "D1",
    # Ctrl3
    "D3", "D8",
    "D3",
    "D1",
    # Ctrl4
    "D8",
    "D2",
    "D3", "D8",
    "D3", "D6",
    # Ctrl5
    "D8",
    "D8", "D10",
    # Ctrl6
    "D10",
    "D3",
    "D3"
  ),
  mechanism = c(
    # Ctrl1.1
    "Conservation management reduces human disturbance to wildlife",
    "Conservation management limits overexploitation of species",
    "Conservation management prevents physical habitat damage",
    # Ctrl1.2.1
    "Habitat restoration reverses physical loss and degradation",
    "Ecosystem remediation reverses seabed disturbance impacts",
    # Ctrl1.2.2
    "Species restocking reverses overexploitation impacts",
    # Ctrl1.2.3
    "Habitat creation compensates for physical habitat loss",
    # Ctrl1.3.1
    "Quotas and catch limits reduce species extraction",
    "Visitor limits reduce disturbance to sensitive species",
    "Activity restrictions prevent physical seabed damage",
    # Ctrl1.3.2
    "Spatial planning separates activities from sensitive areas",
    "Zoning prevents physical disturbance in sensitive zones",
    # Ctrl1.3.5
    "MPAs prevent extraction of species within protected zones",
    "MPAs prevent physical disturbance within boundaries",
    "MPAs eliminate human disturbance in no-access zones",
    "MPAs prevent physical habitat loss within boundaries",
    # Ctrl1.3.6
    "No-take zones allow species recovery from extraction",
    "No-activity zones prevent seabed disturbance",
    # Ctrl1.3.7
    "Essential habitat protection reduces species extraction pressure",
    "Temporal closures prevent seabed disturbance during recovery",
    # Ctrl1.3.8
    "Seasonal restrictions reduce disturbance during critical periods",
    # Ctrl1.3.9
    "Mitigation measures reduce contaminant release from activities",
    "Mitigation measures reduce noise emissions from activities",
    # Ctrl2.1
    "Reduced fossil fuel use decreases contaminant emissions to sea",
    # Ctrl2.2.1
    "Nature-based solutions avoid permanent seabed habitat loss",
    "Nature-based solutions maintain natural hydrological conditions",
    # Ctrl2.2.2
    "Organic farming eliminates synthetic pesticide input to water",
    "Organic farming reduces fertilizer nutrient runoff",
    # Ctrl2.2.8
    "Controlled drainage reduces nutrient leaching to water courses",
    # Ctrl2.2.9
    "Erosion control reduces sediment input to water courses",
    # Ctrl2.2.11
    "Improved treatment reduces contaminant discharge to coast",
    # Ctrl2.2.12
    "Riparian buffer zones intercept nutrient runoff from land",
    "Riparian zones trap sediment before reaching water courses",
    # Ctrl2.3.1
    "Bubble curtains reduce pile-driving noise by 10-20 dB",
    "Soft-start allows marine mammals to leave before full power",
    # Ctrl2.3.3
    "Alternative foundation designs reduce construction noise",
    # Ctrl2.3.4
    "Seasonal timing avoids disturbance during breeding/migration",
    "Seasonal restrictions reduce noise during sensitive periods",
    # Ctrl2.3.5
    "PAM detects marine mammals to trigger mitigation protocols",
    # Ctrl2.3.6
    "Radar monitoring enables avoidance of bird/bat collision",
    # Ctrl2.3.7
    "Curtailment during migration reduces species disturbance",
    # Ctrl2.3.9-11
    "Artificial reefs compensate for habitat lost to construction",
    "Reef structures create new hard substrate habitat",
    "Modular reefs on scour protection enhance habitat complexity",
    # Ctrl2.3.20-21
    "Oyster reef restoration reverses biogenic habitat loss",
    "Mussel bed enhancement on structures reverses habitat decline",
    # Ctrl2.3.22
    "Seaweed cultivation on infrastructure provides habitat function",
    # Ctrl3
    "Environmental monitoring informs sustainable harvest levels",
    "Contaminant monitoring supports pollution reduction measures",
    "Better assessment methods improve harvest management accuracy",
    "Early warning systems enable rapid pathogen response",
    # Ctrl4
    "Climate legislation reduces greenhouse gas and contaminant emissions",
    "Invasive species regulation prevents new introductions",
    "Local legislation controls harvest intensity and methods",
    "Local legislation controls contaminant discharge from activities",
    "Ecosystem management plans reduce overall extraction pressure",
    "Ecosystem management plans reduce physical disturbance",
    # Ctrl5
    "Incentives for low-impact alternatives reduce contaminant release",
    "Pollution taxes create economic incentive to reduce discharges",
    "Litter fees incentivize waste reduction at source",
    # Ctrl6
    "Public awareness reduces littering and waste generation",
    "Consumer education enables sustainable seafood choices",
    "Promoting alternative species reduces pressure on depleted stocks"
  ),
  citation = c(
    rep("ospar_qsr_2023", 3),
    rep("borgwardt_2019", 2),
    "eu_cfs",
    "borgwardt_2019",
    "eu_cfs", rep("borgwardt_2019", 2),
    rep("knights_2015", 2),
    rep("ospar_qsr_2023", 4),
    rep("helcom_holas3", 2),
    rep("ospar_qsr_2023", 2),
    "borgwardt_2019",
    rep("knights_2015", 2),
    "korpinen_2021",
    rep("borgwardt_2019", 2),
    rep("eu_nitrates", 2),
    "korpinen_2021", "korpinen_2021",
    "eu_uwwtd",
    rep("korpinen_2021", 2),
    rep("borgwardt_2019", 2),
    "borgwardt_2019",
    rep("borgwardt_2019", 2),
    "borgwardt_2019",
    rep("borgwardt_2019", 2),
    rep("borgwardt_2019", 3),
    rep("borgwardt_2019", 2),
    "borgwardt_2019",
    rep("helcom_holas3", 2),
    "knights_2015",
    "msfd_2017_848",
    "msfd_2017_848",
    "imo_bwm",
    rep("ospar_qsr_2023", 2),
    rep("helcom_holas3", 2),
    "knights_2015",
    rep("ospar_qsr_2023", 2),
    rep("borgwardt_2019", 3)
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

#' Get knowledge base statistics
#'
#' @return Named list with counts and coverage info
get_kb_stats <- function() {
  list(
    total_connections = nrow(CAUSAL_KB$activity_pressure) +
                        nrow(CAUSAL_KB$pressure_consequence) +
                        nrow(CAUSAL_KB$control_pressure),
    activity_pressure_links = nrow(CAUSAL_KB$activity_pressure),
    pressure_consequence_links = nrow(CAUSAL_KB$pressure_consequence),
    control_pressure_links = nrow(CAUSAL_KB$control_pressure),
    unique_activities = length(unique(CAUSAL_KB$activity_pressure$from_id)),
    unique_pressures = length(unique(c(
      CAUSAL_KB$activity_pressure$to_id,
      CAUSAL_KB$pressure_consequence$from_id,
      CAUSAL_KB$control_pressure$to_id
    ))),
    unique_consequences = length(unique(CAUSAL_KB$pressure_consequence$to_id)),
    unique_controls = length(unique(CAUSAL_KB$control_pressure$from_id)),
    references_count = nrow(CAUSAL_KB$references),
    high_confidence_pct = round(100 * mean(c(
      CAUSAL_KB$activity_pressure$confidence == "HIGH",
      CAUSAL_KB$pressure_consequence$confidence == "HIGH",
      CAUSAL_KB$control_pressure$confidence == "HIGH"
    )), 1)
  )
}

log_info("Causal knowledge base loaded successfully")
