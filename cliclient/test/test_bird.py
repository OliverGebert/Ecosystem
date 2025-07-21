import pytest

from Eco.bird import Duck, Gull, Swan


class TestGull:

    @pytest.fixture
    def gull(self):
        return Gull()

    def test_update(self, gull):
        assert gull.getDescription() == "Gull and I walk"

    def test_move(self, gull):
        assert gull.moveBehavior.move() == "I walk"

    def test_performQuak(self, gull):
        assert gull.performQuack() == "squawk"


class TestDuck:

    @pytest.fixture
    def duck(self):
        return Duck()

    def test_update(self, duck):
        assert duck.getDescription() == "Duck and I fly"

    def test_move(self, duck):
        assert duck.moveBehavior.move() == "I fly"

    def test_performQuak(self, duck):
        assert duck.performQuack() == "quack"


class TestSwan:

    @pytest.fixture
    def swan(self):
        return Swan()

    def test_update(self, swan):
        assert swan.getDescription() == "Swan and I swim"

    def test_move(self, swan):
        assert swan.moveBehavior.move() == "I swim"

    def test_performQuak(self, swan):
        assert swan.performQuack() == "honk"
