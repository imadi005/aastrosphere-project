const VIBE_TAGS = {
    1: 'Initiative, Leadership, Courage',
    2: 'Balance, Partnership, Harmony',
    3: 'Creativity, Joy, Expression',
    4: 'Stability, Structure, Order',
    5: 'Freedom, Adventure, Change',
    6: 'Love, Responsibility, Family',
    7: 'Introspection, Spirituality, Analysis',
    8: 'Power, Authority, Material Success',
    9: 'Compassion, Humanitarianism, Philanthropy'
};

const VIBE_TAG_SELECTOR = {
    selectVibes: function(dailyNumbers, mahaNumbers, antarNumbers, activeYogas) {
        const allVibes = [
            ...dailyNumbers.map(num => VIBE_TAGS[num]),
            ...mahaNumbers.map(num => VIBE_TAGS[num]),
            ...antarNumbers.map(num => VIBE_TAGS[num]),
            ...activeYogas.map(yoga => VIBE_TAGS[yoga])
        ];
        
        const vibeCount = {};
        
        allVibes.forEach(vibe => {
            vibeCount[vibe] = (vibeCount[vibe] || 0) + 1;
        });
        
        const topVibes = Object.entries(vibeCount)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 3)
            .map(([vibe]) => vibe);
        
        return topVibes;
    }
};

module.exports = {
    VIBE_TAGS,
    VIBE_TAG_SELECTOR
};
