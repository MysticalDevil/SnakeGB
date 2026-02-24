# UI Review Notes

## High Priority (Readability/Consistency/Interaction)
1. **Gameplay/Replay/Level-Up background unification** `[Done]`
   - **Issue:** gameplay/replay are darker than menu due to LCD shader + history mix; level-up overlay still feels blended with gameplay.
   - **Recommendation:** introduce a unified `sceneBase` layer for `Playing/Replaying/ChoiceSelection` (solid `cardPrimary` + subtle grid) and tune shader strength per state. Ensure overlays fully cover game content when active.
   - **Status:** `sceneBase` + shared grid + `lumaBoost` applied for gameplay/replay/choice + static debug game/replay.

2. **Overlay layering and clarity** `[Done]`
   - **Issue:** overlays can appear hazy when mixed with shader history.
   - **Recommendation:** keep overlay backgrounds opaque (or near-opaque) and avoid additive transparency. Centralize overlay z-ordering so UI is always above gameplay.
   - **Status:** opaque paused/gameover overlays, replay banner opacity lifted, unified overlay z ordering.

3. **Choice (Roguelike) cards contrast** `[Done]`
   - **Issue:** card/background contrast shifts too much across palettes.
   - **Recommendation:** constrain card colors to `cardSecondary`/`actionCard` and keep text in `titleInk/secondaryInk`.
   - **Status:** choice card text uses `titleInk/secondaryInk`; selection keeps `actionCard`/`cardSecondary`.

4. **HUD visibility vs overlays**
   - **Issue:** HUD overlaps with Level-Up content.
   - **Recommendation:** disable HUD during `ChoiceSelection` and any modal overlays.

5. **Buff info readability**
   - **Issue:** buff banner can be washed out on some palettes.
   - **Recommendation:** use solid `cardPrimary` background and `titleInk` text; optionally add subtle outline/shadow for text.

## Medium Priority (Style Consistency)
6. **Menu/Library/MedalRoom theme alignment**
   - **Issue:** pages feel disconnected due to different theme sources.
   - **Recommendation:** reuse `menuColor` palette and apply page variants only as subtle accents.

7. **LCD shader tuning controls**
   - **Issue:** fixed ghosting/scanline intensity causes darkening.
   - **Recommendation:** expose shader parameters (ghostMix, scanlineStrength, gridStrength) and adjust per state.

8. **Debug pages styling**
   - **Issue:** debug views are functional but not visually aligned with the core UI language.
   - **Recommendation:** keep debug screens minimal but reuse base colors and title/header styling.

## Low Priority (Aesthetics/Polish)
9. **Button/DPad lighting consistency**
   - **Issue:** some button shadows feel mismatched.
   - **Recommendation:** unify shadow radius/intensity and highlight direction across components.

10. **Screenshot tooling**
    - **Issue:** palette checks are manual and scattered.
    - **Recommendation:** provide a single script target to capture menu/game/replay/choice and emit a small HTML or montage for visual review.
