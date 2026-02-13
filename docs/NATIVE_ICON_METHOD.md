# Create App Icon Using Native Mac Tools (2 Minutes!)

## Method: Keynote (Pre-installed on Mac) ⭐

### Step 1: Create Canvas in Keynote
1. Open **Keynote**
2. Choose any theme → Click "Create"
3. Delete all text boxes (select and press Delete)
4. Top menu: **File** → **Page Setup**
   - Paper Size: **Custom**
   - Width: **1024 pt**
   - Height: **1024 pt**
5. Click **OK**

### Step 2: Add Orange Background
1. In the sidebar, click the slide
2. **Format** panel (right side) → **Background**
3. Choose **Gradient Fill**
4. Set colors:
   - Top color: Click color picker → **RGB Sliders**
     - R: 255, G: 149, B: 0 (Orange)
   - Bottom color:
     - R: 255, G: 200, B: 0 (Yellow-Orange)
5. Adjust gradient angle if desired

### Step 3: Add Test Tube Symbol
1. Click **Insert** (toolbar) → **Shape** → **SF Symbol**
2. Search for "**testtube.2**"
3. Click to insert
4. Resize to fill about 60% of the slide
5. Center it (use alignment guides)
6. **Format** panel → **Style**:
   - Color: **White**
   - Remove any shadow if present

### Step 4: Export as Image
1. **File** → **Export To** → **Images...**
2. Format: **PNG**
3. Click **Next**
4. Save as `AppIcon-1024.png`

### Step 5: Add to Xcode
1. Open Xcode project
2. **Assets.xcassets** → **AppIcon**
3. Drag `AppIcon-1024.png` into the **1024x1024** slot
4. Done! ✅

---

## Alternative: Pages (Also Pre-installed)

Same process in Pages:
1. Open Pages → Blank document
2. Format → Document → Change to 1024x1024 pt
3. Add rectangle (full size) with orange gradient
4. Insert → SF Symbol → testtube.2 (white)
5. Export as PNG

---

## Alternative: Preview.app (Simplest for Quick Test)

1. Open **Preview**
2. **File** → **New from Clipboard** (or create new)
3. **Tools** → **Adjust Size** → 1024x1024
4. Use **Markup** tools to add shapes
5. Note: Preview doesn't have SF Symbols, so use this for background only

---

## No Keynote? Use Online Tool

1. Go to **https://www.photopea.com** (free Photoshop alternative)
2. Create new: 1024x1024 px
3. Gradient tool: Orange (#FF9500) to Yellow (#FFC800)
4. Text tool: Use "🧪" emoji (or find test tube icon)
5. Make it white and large (~600px)
6. Export as PNG

---

## Colors Reference

**Orange Gradient:**
- Top: RGB(255, 149, 0) = #FF9500
- Bottom: RGB(255, 200, 0) = #FFC800

**Symbol:**
- White: RGB(255, 255, 255) = #FFFFFF
- Size: ~600px (60% of 1024px)

This should take about 2-3 minutes total! 🎉
