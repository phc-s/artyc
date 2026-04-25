package artyc;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferStrategy;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

public class Artyc extends Canvas implements Runnable {
    
    private static final long serialVersionUID = 1L;
    private boolean running = false;
    private Thread gameThread;
    
    private int WORLD_WIDTH = 2000;
    private int WORLD_HEIGHT = 2000;
    private double cameraX, cameraY;
    private double dx = 0, dy = 0;
    private double x = 600, y = 500;
    private double velocity = 0;
    private double angle = 0;
    
    private double steeringInput = 0;     
    private final double STEER_SENSE = 0.01; 
    private final double STEER_RETURN = 0.01; 
    
    private final double ACCEL = 0.02;
    private final double FRICTION = 0.99;
    private final double MAX_SPEED = 10.00;
    
    private boolean up, down, left, right;
    private BufferedImage carImg, mapImg;

    public Artyc() {
    	
        try {
            carImg = ImageIO.read(getClass().getResourceAsStream("/asset/car.png"));
            mapImg = ImageIO.read(getClass().getResourceAsStream("/asset/map.png"));
            
            if (mapImg != null) {
                WORLD_WIDTH = mapImg.getWidth();
                WORLD_HEIGHT = mapImg.getHeight();
            }
        } catch (Exception e) {
            System.out.println("Error loading assets: " + e.getMessage());
        }

        this.addKeyListener(new KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent e) { updateKey(e.getKeyCode(), true); }
            @Override
            public void keyReleased(KeyEvent e) { updateKey(e.getKeyCode(), false); }
        });
    }

    private void updateKey(int code, boolean pressed) {
        if (code == KeyEvent.VK_UP) up = pressed;
        if (code == KeyEvent.VK_DOWN) down = pressed;
        if (code == KeyEvent.VK_LEFT) left = pressed;
        if (code == KeyEvent.VK_RIGHT) right = pressed;
    }
    
    public synchronized void start() {
        running = true;
        gameThread = new Thread(this);
        gameThread.start();
    }

    @Override
    public void run() {
        this.requestFocus();
        long lastTime = System.nanoTime();
        double ns = 1000000000 / 60.0;
        double delta = 0;

        while (running) {
            long now = System.nanoTime();
            delta += (now - lastTime) / ns;
            lastTime = now;
            
            while (delta >= 1) {
                updatePhysics();
                delta--;
            }
            render();
            try { Thread.sleep(2); } catch (Exception e) {}
        }
    }

    private void updatePhysics() {
        velocity *= FRICTION;	
        if (up) velocity += ACCEL;
        if (down) velocity -= ACCEL * 2.0;
        velocity = Math.clamp(velocity, -MAX_SPEED / 2, MAX_SPEED);

        double speedFactor = Math.abs(velocity) / MAX_SPEED;
        double currentSteerSense = STEER_SENSE * (1.0 - (speedFactor * 0.4)); 
        if (left) steeringInput -= currentSteerSense; 
        else if (right) steeringInput += currentSteerSense;
        else {
            if (Math.abs(steeringInput) < STEER_RETURN) steeringInput = 0;
            else steeringInput -= Math.signum(steeringInput) * STEER_RETURN;
        }
        steeringInput = Math.clamp(steeringInput, -1.0, 1.0);

        angle += steeringInput * (Math.abs(velocity) * 0.02);

        double targetDx = Math.cos(angle) * velocity;
        double targetDy = Math.sin(angle) * velocity;
        double grip = 0.12; 
        dx += (targetDx - dx) * grip;
        dy += (targetDy - dy) * grip;

        x += dx;
        y += dy;

        x = Math.clamp(x, 0, WORLD_WIDTH);
        y = Math.clamp(y, 0, WORLD_HEIGHT);
        
        if (x <= 0 || x >= WORLD_WIDTH || y <= 0 || y >= WORLD_HEIGHT) velocity *= 0.5;
        
    }

    private void render() {
    	
        BufferStrategy bs = this.getBufferStrategy();
        if (bs == null) {
            this.createBufferStrategy(3);
            return;
        }
        Graphics2D g = (Graphics2D) bs.getDrawGraphics();

        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);

        cameraX = x - (getWidth() / 2.0);
        cameraY = y - (getHeight() / 2.0);

        g.setColor(Color.WHITE); 
        g.fillRect(0, 0, getWidth(), getHeight());

        AffineTransform worldAt = new AffineTransform();
        worldAt.translate(-cameraX, -cameraY); // Shift world based on camera
        
        g.drawImage(mapImg, worldAt, null);

        AffineTransform carAt = new AffineTransform();
        carAt.translate(getWidth() / 2.0, getHeight() / 2.0); 
        carAt.rotate(angle);   
        carAt.translate(-carImg.getWidth() / 2.0, -carImg.getHeight() / 2.0);
        g.drawImage(carImg, carAt, null);

        g.dispose();
        bs.show();
    }

    public static void main(String[] args) {
        System.setProperty("sun.java2d.opengl", "true");
        JFrame frame = new JFrame("Artyc");
        Artyc game = new Artyc();
        frame.add(game);
        frame.setSize(600, 500);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setResizable(true);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        game.start();
    }
}