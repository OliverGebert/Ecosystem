import pytest

from Eco.lake import Lake


class TestLake:

    @pytest.fixture
    def lake(self):
        return Lake(5, 10)

    def test_registerObserver(self, lake):
        for d in range(lake.capacity):
            lake.registerObserver("bird", 2)
            assert lake.getCount() == d+1
            assert lake.getDanger() == 2*(d+1)
        lake.registerObserver("bird", 2)
        assert lake.getCount() == lake.capacity
