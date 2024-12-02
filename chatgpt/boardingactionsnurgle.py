from itertools import combinations

# Define unit data
units_list1 = {
    "poxbringer": 55,
    "Sloppity Bilepiper": 55,
    "epidemius": 80,
    "Spoilpox Scrivener": 60
}

units_list2 = {
    "plaguebearers": 110,
    "nurglings": 40
}

units_list3 = {
    "Beasts of nurgle": 65
}

# Helper function to calculate total points
def calculate_points(combo):
    return sum(cost for _, cost in combo)

# Generate all valid combinations
valid_combinations = []

# Select two units from list1 (no duplicates)
for combo1 in combinations(units_list1.items(), 2):
    # Pick up to 3 duplicates for each unit in list2
    for num_plaguebearers in range(4):  # Allowing up to 3 plaguebearers
        for num_nurglings in range(4):  # Allowing up to 3 nurglings
            plaguebearer_combo = [("plaguebearers", 110)] * num_plaguebearers
            nurglings_combo = [("nurglings", 40)] * num_nurglings
            
            # Pick up to 2 "Beasts of nurgle"
            for num_beasts in range(3):  # Allowing up to 2 beasts of nurgle
                beasts_combo = [("Beasts of nurgle", 65)] * num_beasts

                # Combine all selected units into a single list
                combined_units = list(combo1) + plaguebearer_combo + nurglings_combo + beasts_combo
                
                # Calculate total points
                total_points = calculate_points(combined_units)
                if total_points <= 500:
                    valid_combinations.append((combined_units, total_points))

# Sort the combinations by points in ascending order
valid_combinations.sort(key=lambda x: x[1])

# Filter combinations with more than 440 points
filtered_combinations = [combo for combo in valid_combinations if combo[1] > 440]

# Define unit images
unit_images = {
    "poxbringer": "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fageofsigmar.lexicanum.com%2Fmediawiki%2Fimages%2Fthumb%2Fe%2Fe0%2FPoxbringer_M01.jpg%2F174px-Poxbringer_M01.jpg&f=1&nofb=1&ipt=5785efa1345d56f97b9259a7fda183ce4af7000caf64a05d5c55e72510368088&ipo=images",
    "Sloppity Bilepiper": "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fageofsigmar.lexicanum.com%2Fmediawiki%2Fimages%2Fthumb%2F8%2F81%2FSloppity_Bilepiper_M01.jpg%2F116px-Sloppity_Bilepiper_M01.jpg&f=1&nofb=1&ipt=e53b0c7c1f5f63d89e4de1865ebfb2ab2a750e59a836aa30e031597b6e2d2a0d&ipo=images",
    "epidemius": "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fb.thumbs.redditmedia.com%2FI14wt4fTPzaq6Xlor9X4WWFxPrMa9Xgs8TNY2PjR_Gw.jpg&f=1&nofb=1&ipt=8cb080d17af36084a1eb14675aa9297c3439b84d535e334212ae28a949f03a6e&ipo=images",
    "Spoilpox Scrivener": "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.goldengoblingames.com%2Fmedia%2Fcatalog%2Fproduct%2Fcache%2F18b41565f75cec50580715a505626f77%2Fg%2Fa%2Fgaw-99079915003-02.jpg&f=1&nofb=1&ipt=592e820f1b140fe83996286885654cf26c44f6d92bd9af82ad647690f5c19d16&ipo=images",
    "plaguebearers": "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwh40k.lexicanum.com%2Fmediawiki%2Fimages%2F4%2F49%2FPlaguebearer1st.jpg&f=1&nofb=1&ipt=438aef1c5e4a4bf98bff77ba51b903286140467cf1e413c6cab2180edccc171d&ipo=images",
    "nurglings": "https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fnurgle.stelio.net%2Fcomponents%2Fepic_guo_1.jpg&f=1&nofb=1&ipt=e338e7e90e3e178e1ec513a5cfd41f69057c85f2d26c859d61a6495466789184&ipo=images",
    "Beasts of nurgle": "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwhfb.lexicanum.com%2Fmediawiki%2Fimages%2Fthumb%2Fa%2Fad%2FBeast_of_Nurgle_WD.jpg%2F120px-Beast_of_Nurgle_WD.jpg&f=1&nofb=1&ipt=10ec1cb3d68751ad83fa2c8aa8d2267e2c1ed2b03a2c037d9a5d6b2b3ee7bae4&ipo=images"
}

# Add the rest of the HTML generation code as provided earlier
# Ensure it uses the filtered_combinations list
# Enhanced HTML with max filter limits based on combination constraints
html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Unit Combinations with Advanced Filters</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .filters {
            margin-bottom: 20px;
        }
        .filter-section {
            margin-bottom: 10px;
        }
        .combination {
            border: 1px solid #ccc;
            margin-bottom: 20px;
            padding: 10px;
            border-radius: 8px;
            background-color: #f9f9f9;
            display: none; /* Hidden by default, shown by filter */
        }
        .unit {
            display: inline-block;
            text-align: center;
            margin: 10px;
        }
        .unit img {
            width: 100px;
            height: 100px;
            border-radius: 8px;
        }
        .unit-name {
            margin-top: 5px;
            font-weight: bold;
        }
        .total-points {
            font-size: 18px;
            font-weight: bold;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h1>Unit Combinations with Advanced Filters (Points > 440)</h1>
    <div class="filters">
        <h2>Filters</h2>
        <div class="filter-section">
            <label for="unit-select">Select Units and Counts:</label><br>
"""

# Add unit count filters with constraints based on max occurrences in combinations
unit_max_counts = {
    "poxbringer": 1,
    "Sloppity Bilepiper": 1,
    "epidemius": 1,
    "Spoilpox Scrivener": 1,
    "plaguebearers": 3,
    "nurglings": 3,
    "Beasts of nurgle": 2
}

for unit, max_count in unit_max_counts.items():
    html_content += f"""
            <label>{unit}:</label>
            <select id="filter-{unit.replace(' ', '-')}">
                <option value="">Any</option>
    """
    for count in range(max_count + 1):  # Generate options based on max count
        html_content += f"<option value='{count}'>{count}</option>"
    html_content += "</select><br>"

html_content += """
        </div>
        <div class="filter-section">
            <label for="min-points">Minimum Points:</label>
            <input type="number" id="min-points" value="440" min="0"><br>
            <label for="max-points">Maximum Points:</label>
            <input type="number" id="max-points" value="500" min="0"><br>
        </div>
        <button onclick="applyFilters()">Apply Filters</button>
    </div>
    <div id="combinations">
"""

# Add each combination to the HTML
for i, (units, points) in enumerate(filtered_combinations[:50]):  # Limiting to top 50 combinations for brevity
    combination_id = f"combination-{i}"
    unit_data = {unit: 0 for unit in unit_images.keys()}
    for unit, _ in units:
        unit_data[unit] += 1
    unit_classes = " ".join([f"{unit.replace(' ', '-')}-{count}" for unit, count in unit_data.items() if count > 0])
    html_content += f'<div class="combination {unit_classes}" id="{combination_id}" data-points="{points}">\n'
    html_content += f'<div class="total-points">Total Points: {points}</div>\n'
    for unit, count in units:
        image_url = unit_images.get(unit, "https://via.placeholder.com/100?text=Unknown")
        html_content += f"""
        <div class="unit">
            <img src="{image_url}" alt="{unit}">
            <div class="unit-name">{unit} x{count}</div>
        </div>
        """
    html_content += '</div>\n'

# Close combinations div
html_content += """
    </div>
    <script>
function applyFilters() {
    const minPoints = parseInt(document.getElementById('min-points').value) || 0;
    const maxPoints = parseInt(document.getElementById('max-points').value) || 500;
    
    // Get unit-specific filters
    const unitFilters = {};
    const unitSelects = document.querySelectorAll("[id^=filter-]");
    unitSelects.forEach(select => {
        const unit = select.id.replace('filter-', '').replace('-', ' ');
        const value = select.value;
        if (value !== "") {
            unitFilters[unit] = parseInt(value);
        }
    });

    // Get all combinations
    const combinations = document.querySelectorAll('.combination');
    
    combinations.forEach(combination => {
        const points = parseInt(combination.getAttribute('data-points'));
        const combinationClasses = combination.className.split(' ');
        
        // Check points filter
        const pointsMatch = points >= minPoints && points <= maxPoints;

        // Check unit count filters
        let unitsMatch = true;
        for (const [unit, count] of Object.entries(unitFilters)) {
            const unitClass = `${unit.replace(' ', '-')}-${count}`;
            
            if (count === 0) {
                // If the filter is set to zero, ensure the combination does NOT include the unit
                if (combinationClasses.some(cls => cls.startsWith(`${unit.replace(' ', '-')}-`))) {
                    unitsMatch = false;
                    break;
                }
            } else {
                // For non-zero counts, ensure the combination includes the unit with the exact count
                if (!combinationClasses.includes(unitClass)) {
                    unitsMatch = false;
                    break;
                }
            }
        }
        
        // Show or hide based on filters
        if (pointsMatch && unitsMatch) {
            combination.style.display = 'block';
        } else {
            combination.style.display = 'none';
        }
    });
}
    </script>
</body>
</html>
"""

# Save the enhanced HTML content to a file
output_path_with_constraints = "filtered_combinations_with_constraints.html"
with open(output_path_with_constraints, "w") as file:
    file.write(html_content)

import webbrowser
webbrowser.get("chromium").open(output_path_with_constraints)
