var spriteList = [];

/*  string[] getSmartFolderName()

    This is for use with the "Prepend folder name" option in TP GUI.
    Splits a sprites trimmed name at first "/" and uses first item to 
    get smart folder name if a "/" exists.
    [
        "smartFolderName/",
        "smartFolderName"
    ]
*/
const getSmartFolderName = (spriteTrimmedName) => spriteTrimmedName.match(/(.+)[\/]/)[1];

/*  string[] getSpriteNameAndFrame()

    This takes a sprites trimmedName and splits it at the last underscore in string.
    [
        "someSpriteNameTrimmed_000", // input String value
        "someSpriteNameTrimmed",     // sprite name without the frame number e.g.
        "000"                        // sprite frame number e.g.
    ]
 */
const getSpriteNameAndFrame = (spriteTrimmedName) => spriteTrimmedName.match(/(.+)[-_.\//](\d+)$/);

const getBitmapTableName = (spriteTrimmedName) => spriteTrimmedName.match(/^[^-]*/)[0];

const isFrameRectEqual = (spriteA, spriteB) => (
    spriteA.frameRect.x         === spriteB.frameRect.x && 
    spriteA.frameRect.y         === spriteB.frameRect.y &&
    spriteA.frameRect.width     === spriteB.frameRect.width &&
    spriteA.frameRect.height    === spriteB.frameRect.height
);

const uniqueSprites = (allSprites) => allSprites.filter(
    (sprite, index) => allSprites.findIndex((item) => isFrameRectEqual(item, sprite)) === index
);

// Returns array of frames [x,y,width,height,spriteIndex]
const exportSpriteData = (root) => {
    let texture = root.texture;
    spriteList = uniqueSprites(texture.allSprites);
    
    let spriteData = [];
    for (var spriteIndex = 0; spriteIndex < spriteList.length; spriteIndex++)
    {
        let sprite = spriteList[spriteIndex];
        let frameValues = {
            name: sprite.trimmedName,
            x: sprite.frameRect.x,
            y: sprite.frameRect.y,
            width: sprite.frameRect.width,
            height: sprite.frameRect.height,
            index: spriteIndex,
        };
        spriteData.push(frameValues);
    }

    return spriteData;
}

// Creates keys on animations object where key is the name of an animation and the value is an array of the
// index of the sprite within the spritesheet.
const exportAnimations = (root) => {
    let texture = root.texture;
    let animations = [];

    for (let spriteIndex = 0; spriteIndex < texture.allSprites.length; spriteIndex++)
    {
        let sprite = texture.allSprites[spriteIndex];
        let spriteName = sprite.trimmedName;
        
        let nameAndFrame = getSpriteNameAndFrame(spriteName);
        if (nameAndFrame)
        {
            let name = nameAndFrame[1];
            let smartFolderName = getSmartFolderName(spriteName);

            if(smartFolderName) 
            {
                name = smartFolderName;
            }

            if (!animations.find(item => item.name === name))
            {
                animations.push({
                    name,
                    framesLength: 0,
                    frames: []
                });
            }

            // if the first index is 1, minus 1 from the index to correctly set first animation frame array index
            let frameIndex = parseInt(nameAndFrame[2], 10);
            let spriteIndex = spriteList.findIndex((item) => isFrameRectEqual(sprite, item));
            let animationFrameIndex = frameIndex;

            animations.find(item => item.name === name).frames[animationFrameIndex] = spriteIndex;
        }
    }

    animations.forEach(animation => animation.framesLength = animation.frames.length);

    return animations;
}

const formatArrays = (key, value) => {
    if (Array.isArray(value) && !value.some(x => x && typeof x === 'object')) {
        return `\uE000${
            JSON.stringify(
                value.map(v => typeof v === 'string' ? 
                v.replace(/"/g, '\uE001') : 
                v)
            )
        }\uE000`;
    }
    return value;
}

const prettyPrintJSON = (obj, indent = 2) => {
  return JSON.stringify(obj, (k, v) => formatArrays(k, v), indent)
    .replace(/"\uE000([^\uE000]+)\uE000"/g, match => match.substr(2, match.length - 4)
    .replace(/\\"/g, '"')
    .replace(/\uE001/g, '\\\"'));
}

var exportData = (root) => {
    let texture = root.texture;

    let data = {
        imagePath: root.settings.textureSubPath + texture.fullName,
        bitmapTablePath: root.settings.textureSubPath + getBitmapTableName(texture.trimmedName),
        totalBits: texture.area,
        width: texture.size.width,
        height: texture.size.height,
        framerate: parseInt(root.exporterProperties.framerate),
        spriteDataLength: uniqueSprites(texture.allSprites).length,
        spriteData: exportSpriteData(root),
    };

    if(root.settings.autodetectAnimations) {
        const animations = exportAnimations(root);
        data.animationsLength = animations.length;
        data.animations = animations;
    }
        

    data.texturepacker = {
        SmartUpdateHash: root.smartUpdateKey,
        app: "Created with TexturePacker (https://www.codeandweb.com/texturepacker) for MattouBatou Playdate"
    }

    return prettyPrintJSON(data, "\t");
}

exportData.filterName = "exportData";
Library.addFilter("exportData");

