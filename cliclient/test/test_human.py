import pytest

from Eco.human import Human, Foto, Gun


class TestHuman:

    @pytest.fixture
    def human(self):
        return Human()

    def test_update(self, human):
        assert human.getDescription() == "I'm human"


class TestFoto:

    @pytest.fixture
    def foto(self):
        return Foto(Human())

    def test_update(self, foto):
        assert foto.getDescription() == "I'm human, foto"


class TestGun:

    @pytest.fixture
    def gun(self):
        return Gun(Human())

    def test_update(self, gun):
        assert gun.getDescription() == "I'm human, gun"
