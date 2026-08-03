-- Make every link open in a new tab by default.
-- Applied at build time via --lua-filter, so Markdown stays clean.
function Link(el)
    el.attributes.target = "_blank"
    -- Prevent the new tab from being able to navigate this page (tabnabbing).
    el.attributes.rel = "noopener noreferrer"
    return el
end
