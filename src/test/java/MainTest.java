import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class MainTest {
    @Test
    public void testAdd() {
        assertEquals(42, Main.add(17, 25));
    }
}
