<!-- META DEFINITIONS -->
@def title       = "Ontario COVID-19 Status"
@def prepath     = "OntarioCOVID19.jl"
@def description = ""
@def authors     = "Jérémy Béjanin"
@def hasplotly   = true

<!--  NAVBAR SPECS -->
@def add_docs     = false
@def add_nav_logo = false

<!-- HEADER SPECS -->
@def use_header_img    = true
@def header_img_path   = "url(\"assets/diagonal-lines.svg\")"
@def header_img_style  = "background-repeat: repeat;"
@def header_margin_top = "50px" <!-- 55-60px ~ touching nav bar -->
@def use_hero          = false
@def add_github_view   = true
@def add_github_star   = false
@def github_repo       = "jebej/OntarioCOVID19"

<!-- SECTION LAYOUT -->
@def section_width = 12

<!-- COLOR PALETTE -->
@def header_color      = "#3f6388"
@def link_color        = "#2669DD"
@def link_hover_color  = "teal"
@def section_bg_color  = "#f6f8fa"
@def footer_link_color = "cornflowerblue"

<!-- CODE LAYOUT -->
@def highlight_theme    = "atom-one-dark"
@def code_border_radius = "10px"
@def code_output_indent = "15px"

<!-- INTERNAL DEFINITIONS -->
@def sections        = Pair{String,String}[]
@def section_counter = 1
@def showall         = false

\newcommand{\center}[1]{~~~<div style="text-align:center;">~~~#1~~~</div>~~~}
